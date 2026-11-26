using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.EntityFrameworkCore;

namespace DentalClinic.Infrastructure.Persistence.Repositories;

public class PatientRepository : IPatientRepository
{
    private readonly ApplicationDbContext _context;

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
