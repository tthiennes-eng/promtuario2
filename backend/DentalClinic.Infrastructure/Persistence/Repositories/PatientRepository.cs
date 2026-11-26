using System.Data;
using System.Data.Common;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;

namespace DentalClinic.Infrastructure.Persistence.Repositories;

public class PatientRepository : IPatientRepository
{
    private readonly ApplicationDbContext _context;

    private sealed record ForeignKeyEdge(
        string ChildTable,
        string ChildColumn,
        string ParentTable,
        string ParentColumn);

    public PatientRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Patient?> GetByIdAsync(Guid id)
    {
        return await _context.Patients
            .FirstOrDefaultAsync(p => p.Id == id);
    }

    public async Task<IEnumerable<Patient>> GetAllAsync(int page, int pageSize, string? searchTerm)
    {
        var query = _context.Patients.AsQueryable();

        if (!string.IsNullOrWhiteSpace(searchTerm))
        {
            searchTerm = searchTerm.ToLower();
            query = query.Where(p =>
                p.FullName.ToLower().Contains(searchTerm) ||
                p.CPF.Contains(searchTerm));
        }

        return await query
            .OrderByDescending(p => p.CreatedAt) // Mostra os mais recentes primeiro
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    public async Task AddAsync(Patient patient)
    {
        // Se o Id vier vazio do Flutter (improvável), gera um novo
        if (patient.Id == Guid.Empty)
        {
            patient.Id = Guid.NewGuid();
        }

        await _context.Patients.AddAsync(patient);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(Patient patient)
    {
        _context.Patients.Update(patient);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Guid id)
    {
        if (!_context.Database.IsRelational())
        {
            await DeleteViaEfCoreAsync(id);
            return;
        }

        await using var transaction = await _context.Database.BeginTransactionAsync();
        var connection = _context.Database.GetDbConnection();
        if (connection.State != ConnectionState.Open)
        {
            await connection.OpenAsync();
        }
        var dbTransaction = transaction.GetDbTransaction();

        var edges = await LoadForeignKeyEdgesAsync(connection, dbTransaction);
        var directPatientColumns = await LoadDirectPatientColumnsAsync(connection, dbTransaction);

        foreach (var (tableName, columnName) in directPatientColumns)
        {
            var alreadyTracked = edges.Any(e =>
                e.ChildTable == tableName &&
                e.ChildColumn == columnName &&
                e.ParentTable == "pacientes");

            if (!alreadyTracked)
            {
                edges.Add(new ForeignKeyEdge(tableName, columnName, "pacientes", "id"));
            }
        }

        var edgesByParent = edges
            .GroupBy(e => e.ParentTable)
            .ToDictionary(g => g.Key, g => g.ToList());

        await DeleteRowsMatchingColumnAsync(
            connection,
            dbTransaction,
            tableName: "pacientes",
            filterColumn: "id",
            filterValues: new List<object> { id },
            edgesByParent: edgesByParent,
            activePath: new HashSet<string>(),
            depth: 0);

        await transaction.CommitAsync();
        _context.ChangeTracker.Clear();
    }

    private async Task DeleteViaEfCoreAsync(Guid id)
    {
        var patient = await _context.Patients.FirstOrDefaultAsync(p => p.Id == id);
        if (patient == null) return;

        var appointments = await _context.Appointments.Where(a => a.PatientId == id).ToListAsync();
        if (appointments.Count > 0) _context.Appointments.RemoveRange(appointments);

        var waitList = await _context.WaitListEntries.Where(w => w.PatientId == id).ToListAsync();
        if (waitList.Count > 0) _context.WaitListEntries.RemoveRange(waitList);

        var changeLogs = await _context.PatientChangeLogs.Where(l => l.PatientId == id).ToListAsync();
        if (changeLogs.Count > 0) _context.PatientChangeLogs.RemoveRange(changeLogs);

        var anamneses = await _context.Anamneses.Where(a => a.PatientId == id).ToListAsync();
        if (anamneses.Count > 0) _context.Anamneses.RemoveRange(anamneses);

        var anexos = await _context.Anexos.Where(a => a.PacienteId == id).ToListAsync();
        if (anexos.Count > 0) _context.Anexos.RemoveRange(anexos);

        var attachments = await _context.Attachments.Where(a => a.PatientId == id).ToListAsync();
        if (attachments.Count > 0) _context.Attachments.RemoveRange(attachments);

        var evolutions = await _context.Evolutions.Where(e => e.PatientId == id).ToListAsync();
        if (evolutions.Count > 0) _context.Evolutions.RemoveRange(evolutions);

        var certificates = await _context.Certificates.Where(c => c.PatientId == id).ToListAsync();
        if (certificates.Count > 0) _context.Certificates.RemoveRange(certificates);

        var odontograms = await _context.Odontograms.Where(o => o.PatientId == id).ToListAsync();
        if (odontograms.Count > 0) _context.Odontograms.RemoveRange(odontograms);

        var prescriptions = await _context.Prescriptions.Where(p => p.PatientId == id).ToListAsync();
        if (prescriptions.Count > 0) _context.Prescriptions.RemoveRange(prescriptions);

        var records = await _context.MedicalRecords.Where(r => r.PatientId == id).ToListAsync();
        if (records.Count > 0) _context.MedicalRecords.RemoveRange(records);

        _context.Patients.Remove(patient);
        await _context.SaveChangesAsync();
    }

    private static async Task<List<ForeignKeyEdge>> LoadForeignKeyEdgesAsync(
        DbConnection connection,
        DbTransaction transaction)
    {
        var edges = new List<ForeignKeyEdge>();
        await using var cmd = connection.CreateCommand();
        cmd.Transaction = transaction;
        cmd.CommandText = @"
            SELECT
                child_cls.relname AS child_table,
                child_att.attname AS child_column,
                parent_cls.relname AS parent_table,
                parent_att.attname AS parent_column
            FROM pg_constraint con
            JOIN pg_class child_cls ON child_cls.oid = con.conrelid
            JOIN pg_namespace child_ns ON child_ns.oid = child_cls.relnamespace
            JOIN pg_class parent_cls ON parent_cls.oid = con.confrelid
            JOIN pg_namespace parent_ns ON parent_ns.oid = parent_cls.relnamespace
            JOIN pg_attribute child_att ON child_att.attrelid = con.conrelid AND child_att.attnum = con.conkey[1]
            JOIN pg_attribute parent_att ON parent_att.attrelid = con.confrelid AND parent_att.attnum = con.confkey[1]
            WHERE con.contype = 'f'
              AND array_length(con.conkey, 1) = 1
              AND child_ns.nspname = 'public'
              AND parent_ns.nspname = 'public';";

        await using var reader = await cmd.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            edges.Add(new ForeignKeyEdge(
                reader.GetString(0),
                reader.GetString(1),
                reader.GetString(2),
                reader.GetString(3)));
        }

        return edges;
    }

    private static async Task<List<(string TableName, string ColumnName)>> LoadDirectPatientColumnsAsync(
        DbConnection connection,
        DbTransaction transaction)
    {
        var result = new List<(string, string)>();
        await using var cmd = connection.CreateCommand();
        cmd.Transaction = transaction;
        cmd.CommandText = @"
            SELECT table_name, column_name
            FROM information_schema.columns
            WHERE table_schema = 'public'
              AND table_name <> 'pacientes'
              AND data_type = 'uuid'
              AND lower(column_name) IN ('paciente_id', 'pacienteid', 'patient_id', 'patientid');";

        await using var reader = await cmd.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            result.Add((reader.GetString(0), reader.GetString(1)));
        }

        return result;
    }

    private static async Task DeleteRowsMatchingColumnAsync(
        DbConnection connection,
        DbTransaction transaction,
        string tableName,
        string filterColumn,
        List<object> filterValues,
        Dictionary<string, List<ForeignKeyEdge>> edgesByParent,
        HashSet<string> activePath,
        int depth)
    {
        if (filterValues.Count == 0 || depth > 8)
        {
            return;
        }

        var pathKey = $"{tableName}.{filterColumn}";
        if (!activePath.Add(pathKey))
        {
            return;
        }

        try
        {
            var distinctValues = filterValues.Distinct().ToList();

            if (edgesByParent.TryGetValue(tableName, out var childEdges))
            {
                foreach (var parentColumnGroup in childEdges.GroupBy(e => e.ParentColumn))
                {
                    var parentValues = await SelectDistinctColumnValuesAsync(
                        connection,
                        transaction,
                        tableName,
                        parentColumnGroup.Key,
                        filterColumn,
                        distinctValues);

                    if (parentValues.Count == 0)
                    {
                        continue;
                    }

                    foreach (var edge in parentColumnGroup)
                    {
                        await DeleteRowsMatchingColumnAsync(
                            connection,
                            transaction,
                            edge.ChildTable,
                            edge.ChildColumn,
                            parentValues,
                            edgesByParent,
                            activePath,
                            depth + 1);
                    }
                }
            }

            const int chunkSize = 500;
            for (var offset = 0; offset < distinctValues.Count; offset += chunkSize)
            {
                var chunk = distinctValues.Skip(offset).Take(chunkSize).ToList();
                await using var deleteCmd = connection.CreateCommand();
                deleteCmd.Transaction = transaction;

                var paramNames = new List<string>(chunk.Count);
                for (var i = 0; i < chunk.Count; i++)
                {
                    var paramName = $"@p{i}";
                    paramNames.Add(paramName);
                    var param = deleteCmd.CreateParameter();
                    param.ParameterName = paramName;
                    param.Value = chunk[i];
                    deleteCmd.Parameters.Add(param);
                }

                deleteCmd.CommandText =
                    $"DELETE FROM \"public\".{QuoteIdentifier(tableName)} " +
                    $"WHERE {QuoteIdentifier(filterColumn)} IN ({string.Join(", ", paramNames)});";

                await deleteCmd.ExecuteNonQueryAsync();
            }
        }
        finally
        {
            activePath.Remove(pathKey);
        }
    }

    private static async Task<List<object>> SelectDistinctColumnValuesAsync(
        DbConnection connection,
        DbTransaction transaction,
        string tableName,
        string selectColumn,
        string filterColumn,
        List<object> filterValues)
    {
        var results = new List<object>();
        const int chunkSize = 500;

        for (var offset = 0; offset < filterValues.Count; offset += chunkSize)
        {
            var chunk = filterValues.Skip(offset).Take(chunkSize).ToList();
            await using var cmd = connection.CreateCommand();
            cmd.Transaction = transaction;

            var paramNames = new List<string>(chunk.Count);
            for (var i = 0; i < chunk.Count; i++)
            {
                var paramName = $"@p{i}";
                paramNames.Add(paramName);
                var param = cmd.CreateParameter();
                param.ParameterName = paramName;
                param.Value = chunk[i];
                cmd.Parameters.Add(param);
            }

            cmd.CommandText =
                $"SELECT DISTINCT {QuoteIdentifier(selectColumn)} " +
                $"FROM \"public\".{QuoteIdentifier(tableName)} " +
                $"WHERE {QuoteIdentifier(filterColumn)} IN ({string.Join(", ", paramNames)}) " +
                $"AND {QuoteIdentifier(selectColumn)} IS NOT NULL;";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var value = reader.GetValue(0);
                if (value != null && value != DBNull.Value)
                {
                    results.Add(value);
                }
            }
        }

        return results.Distinct().ToList();
    }

    private static string QuoteIdentifier(string identifier) =>
        "\"" + identifier.Replace("\"", "\"\"") + "\"";

    public async Task<int> CountAsync(string? searchTerm)
    {
        var query = _context.Patients.AsQueryable();

        if (!string.IsNullOrWhiteSpace(searchTerm))
        {
            searchTerm = searchTerm.ToLower();
            query = query.Where(p =>
                p.FullName.ToLower().Contains(searchTerm) ||
                p.CPF.Contains(searchTerm));
        }

        return await query.CountAsync();
    }

    public async Task AnonymizeAsync(Guid id)
    {
        var patient = await GetByIdAsync(id);
        if (patient != null)
        {
            patient.FullName = "PACIENTE ANONIMIZADO (LGPD)";
            patient.CPF = "00000000000";
            patient.Email = "anonimo@odontoclinica.edu.br";
            patient.Phone = "0000000000";
            patient.Address = null;
            
            await UpdateAsync(patient);
        }
    }
    
    public async Task<IEnumerable<Patient>> GetModifiedSinceAsync(DateTime since, int page = 1, int pageSize = 50)
    {
        return await _context.Patients
            .Where(p => p.LastModifiedAt > since)
            .OrderByDescending(p => p.LastModifiedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }
}
