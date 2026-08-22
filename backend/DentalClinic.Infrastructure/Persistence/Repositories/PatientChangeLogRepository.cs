using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.EntityFrameworkCore;

namespace DentalClinic.Infrastructure.Persistence.Repositories;

/// <summary>
/// Implementação do repositório de histórico de alterações de pacientes.
/// </summary>
public class PatientChangeLogRepository : IPatientChangeLogRepository
{
    private readonly ApplicationDbContext _context;

    public PatientChangeLogRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<PatientChangeLog> CreateAsync(PatientChangeLog log)
    {
        await _context.Set<PatientChangeLog>().AddAsync(log);
        return log;
    }

    public async Task<IEnumerable<PatientChangeLog>> GetByPatientIdAsync(Guid patientId)
    {
        return await _context.Set<PatientChangeLog>()
            .Where(l => l.PatientId == patientId)
            .OrderByDescending(l => l.Timestamp)
            .ToListAsync();
    }

    public async Task<int> SaveChangesAsync()
    {
        return await _context.SaveChangesAsync();
    }
}
