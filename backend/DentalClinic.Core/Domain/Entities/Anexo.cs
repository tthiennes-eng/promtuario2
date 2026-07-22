using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DentalClinic.Core.Domain.Entities;

public class Anexo : Entity
{
    public Guid PacienteId { get; set; }

    [ForeignKey("PacienteId")]
    public virtual Patient? Paciente { get; set; }

    [Required]
    [MaxLength(50)]
    public string Tipo { get; set; } = string.Empty; // 'Radiografia', 'Foto', 'Documento'

    [Required]
    [MaxLength(255)]
    public string Nome { get; set; } = string.Empty;

    [Required]
    public string Url { get; set; } = string.Empty;

    public long Tamanho { get; set; }

    public string? MetaData { get; set; }

    public Guid? CriadoPorId { get; set; }

    [ForeignKey("CriadoPorId")]
    public virtual User? CriadoPor { get; set; }

    public static Anexo Create(Guid pacienteId, string nome, string tipo, string url, long tamanho, Guid criadoPorId)
    {
        return new Anexo
        {
            Id = Guid.NewGuid(),
            PacienteId = pacienteId,
            Nome = nome,
            Tipo = tipo,
            Url = url,
            Tamanho = tamanho,
            CriadoPorId = criadoPorId,
            CreatedAt = DateTime.UtcNow
        };
    }
}
