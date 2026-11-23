using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using DentalClinic.Core.Domain.ValueObjects;

namespace DentalClinic.Core.Domain.Entities;

public class Patient : Entity
{
    [Required]
    [MaxLength(255)]
    public string FullName { get; set; } = string.Empty;

    [MaxLength(255)]
    public string? SocialName { get; set; }

    [Required]
    [MaxLength(14)]
    public string CPF { get; set; } = string.Empty;

    [MaxLength(15)]
    public string? SusNumber { get; set; }

    // CORREÇÃO: Email e Telefone passam a ser opcionais.
    // Antes, o atributo [Required] fazia a validação de modelo do ASP.NET
    // rejeitar (HTTP 400) todo cadastro de paciente vindo do app Flutter
    // que não preenchesse esses campos. O erro era engolido no cliente
    // (catch silencioso), o paciente ficava apenas no banco local e o
    // agendamento falhava com "O paciente selecionado não existe no servidor".
    [EmailAddress]
    [MaxLength(255)]
    public string? Email { get; set; }

    [MaxLength(20)]
    public string? Phone { get; set; }

    public DateTime BirthDate { get; set; }

    [MaxLength(1)]
    public string? Gender { get; set; }

    // Endereço mapeado como JSONB
    public Address? Address { get; set; }

    public bool LgpdConsent { get; set; }

    public bool IsActive { get; set; } = true;
    
    /// <summary>
    /// Data da última modificação do paciente (usada para sincronização entre dispositivos).
    /// Preenchido automaticamente pelo EF Core via configuração.
    /// </summary>
    public DateTime LastModifiedAt { get; set; } = DateTime.UtcNow;

    // Relacionamentos
    public ICollection<Appointment>? Appointments { get; set; }
    public ICollection<Evolution>? Evolutions { get; set; }
    public ICollection<Anexo>? Anexos { get; set; }
}
