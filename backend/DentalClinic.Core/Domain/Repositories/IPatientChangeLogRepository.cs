using DentalClinic.Core.Domain.Entities;
using System.Linq.Expressions;

namespace DentalClinic.Core.Domain.Repositories;

/// <summary>
/// Interface para persistência do histórico de alterações de pacientes.
/// </summary>
public interface IPatientChangeLogRepository
{
    /// <summary>
    /// Cria um novo registro de alteração de paciente.
    /// </summary>
    Task<PatientChangeLog> CreateAsync(PatientChangeLog log);
    
    /// <summary>
    /// Busca todos os logs de alterações de um paciente específico, ordenados por data decrescente.
    /// </summary>
    Task<IEnumerable<PatientChangeLog>> GetByPatientIdAsync(Guid patientId);
    
    /// <summary>
    /// Salva as mudanças no banco de dados.
    /// </summary>
    Task<int> SaveChangesAsync();
}
