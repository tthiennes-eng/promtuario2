using System;

namespace DentalClinic.Core.Domain.Entities;

/// <summary>
/// Registro de alterações feitas nos dados de um paciente.
/// Utilizado para auditoria e conformidade com a LGPD.
/// </summary>
public class PatientChangeLog
{
    public Guid Id { get; set; } = Guid.NewGuid();
    
    /// <summary>
    /// Referência ao paciente alterado.
    /// </summary>
    public Guid PatientId { get; set; }
    
    /// <summary>
    /// ID do usuário que fez a alteração.
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// Nome do usuário no momento da alteração (preservado mesmo se o usuário for renomeado/excluído).
    /// </summary>
    public string UserName { get; set; } = string.Empty;
    
    /// <summary>
    /// Data e hora da alteração em UTC.
    /// </summary>
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    
    /// <summary>
    /// Diferencial das alterações no formato JSON: {"Campo": {"old": ..., "new": ...}}
    /// </summary>
    public string ChangesJson { get; set; } = string.Empty;
    
    // Relacionamento com o paciente
    public Patient? Patient { get; set; }
}
