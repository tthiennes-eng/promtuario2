using DentalClinic.Core.Domain.ValueObjects;

namespace DentalClinic.Core.Domain.Entities;

/// <summary>
/// Entidade que representa um paciente no sistema.
/// </summary>
public sealed class Patient : Entity
{
    /// <summary>
    /// Nome completo do paciente.
    /// </summary>
    public string Name { get; private set; }

    /// <summary>
    /// CPF do paciente (Value Object).
    /// </summary>
    public CPF CPF { get; private set; }

    /// <summary>
    /// Data de nascimento.
    /// </summary>
    public DateTime DateOfBirth { get; private set; }

    /// <summary>
    /// Email (Value Object).
    /// </summary>
    public Email EmailAddress { get; private set; }

    /// <summary>
    /// Telefone de contato.
    /// </summary>
    public string Phone { get; private set; }

    /// <summary>
    /// Endereço (Value Object).
    /// </summary>
    public Address Address { get; private set; }

    /// <summary>
    /// Nome do responsável (se menor de idade).
    /// </summary>
    public string? ResponsibleName { get; private set; }

    /// <summary>
    /// Telefone do responsável.
    /// </summary>
    public string? ResponsiblePhone { get; private set; }

    /// <summary>
    /// Número de documento de identidade (RG, CNH, etc).
    /// </summary>
    public string DocumentNumber { get; private set; }

    /// <summary>
    /// Status do paciente.
    /// </summary>
    public PatientStatus Status { get; private set; }

    private Patient()
    {
        Name = string.Empty;
        CPF = CPF.Create("00000000000");
        EmailAddress = Email.Create("default@example.com");
        Phone = string.Empty;
        Address = Address.Create(".", ".", null, ".", ".", "SP", "00000-000");
        DocumentNumber = string.Empty;
        Status = PatientStatus.Active;
    }

    /// <summary>
    /// Cria um novo paciente com validações.
    /// </summary>
    /// <param name="name">Nome completo.</param>
    /// <param name="cpf">CPF (será validado como Value Object).</param>
    /// <param name="dateOfBirth">Data de nascimento.</param>
    /// <param name="email">Email (será validado como Value Object).</param>
    /// <param name="phone">Telefone.</param>
    /// <param name="address">Endereço (Value Object).</param>
    /// <param name="documentNumber">Número do documento de identidade.</param>
    /// <param name="responsibleName">Nome do responsável (se aplícável).</param>
    /// <param name="responsiblePhone">Telefone do responsável (se aplícável).</param>
    /// <returns>Um novo paciente.</returns>
    public static Patient Create(
        string name,
        string cpf,
        DateTime dateOfBirth,
        string email,
        string phone,
        Address address,
        string documentNumber,
        string? responsibleName = null,
        string? responsiblePhone = null)
    {
        ValidateName(name);
        ValidateDateOfBirth(dateOfBirth);
        ValidatePhone(phone);
        ValidateDocumentNumber(documentNumber);

        if (!string.IsNullOrWhiteSpace(responsiblePhone))
            ValidatePhone(responsiblePhone);

        var patient = new Patient
        {
            Name = name.Trim(),
            CPF = CPF.Create(cpf),
            DateOfBirth = dateOfBirth,
            EmailAddress = Email.Create(email),
            Phone = phone.Trim(),
            Address = address,
            DocumentNumber = documentNumber.Trim(),
            ResponsibleName = string.IsNullOrWhiteSpace(responsibleName) ? null : responsibleName.Trim(),
            ResponsiblePhone = string.IsNullOrWhiteSpace(responsiblePhone) ? null : responsiblePhone.Trim(),
            Status = PatientStatus.Active
        };

        return patient;
    }

    /// <summary>
    /// Calcula a idade atual do paciente.
    /// </summary>
    /// <returns>Idade em anos.</returns>
    public int GetAge()
    {
        var today = DateTime.Today;
        var age = today.Year - DateOfBirth.Year;

        if (DateOfBirth.Date > today.AddYears(-age))
            age--;

        return age;
    }

    /// <summary>
    /// Verifica se o paciente é menor de idade.
    /// </summary>
    /// <returns>Verdadeiro se menor de 18 anos, falso caso contrário.</returns>
    public bool IsMinor() => GetAge() < 18;

    /// <summary>
    /// Desativa o paciente.
    /// </summary>
    public void Deactivate()
    {
        Status = PatientStatus.Inactive;
        UpdatedAt = DateTime.UtcNow;
    }

    /// <summary>
    /// Ativa o paciente.
    /// </summary>
    public void Activate()
    {
        Status = PatientStatus.Active;
        UpdatedAt = DateTime.UtcNow;
    }

    /// <summary>
    /// Anonimiza os dados do paciente (conforme LGPD).
    /// </summary>
    public void AnonymizeData()
    {
        Name = $"Anônimo_{Id}";
        EmailAddress = Email.Create("anonymized@example.com");
        Phone = "0000000000";
        ResponsibleName = null;
        ResponsiblePhone = null;
        Status = PatientStatus.DataAnonymized;
        UpdatedAt = DateTime.UtcNow;

        AddDomainEvent(new PatientDataAnonymizedEvent(Id));
    }

    /// <summary>
    /// Atualiza as informações de contato do paciente.
    /// </summary>
    /// <param name="phone">Novo telefone.</param>
    /// <param name="email">Novo email.</param>
    public void UpdateContactInfo(string phone, string email)
    {
        ValidatePhone(phone);
        Phone = phone.Trim();
        EmailAddress = Email.Create(email);
        UpdatedAt = DateTime.UtcNow;
    }

    private static void ValidateName(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new InvalidOperationException("Nome não pode ser vazio.");

        if (name.Length < 3)
            throw new InvalidOperationException("Nome deve ter no mínimo 3 caracteres.");

        if (name.Length > 255)
            throw new InvalidOperationException("Nome não pode ter mais de 255 caracteres.");
    }

    private static void ValidateDateOfBirth(DateTime dateOfBirth)
    {
        if (dateOfBirth >= DateTime.Today)
            throw new InvalidOperationException("Data de nascimento não pode ser no futuro.");

        var age = DateTime.Today.Year - dateOfBirth.Year;
        if (dateOfBirth.Date > DateTime.Today.AddYears(-age))
            age--;

        if (age > 150)
            throw new InvalidOperationException("Data de nascimento inválida.");
    }

    private static void ValidatePhone(string phone)
    {
        if (string.IsNullOrWhiteSpace(phone))
            throw new InvalidOperationException("Telefone não pode ser vazio.");

        var onlyNumbers = System.Text.RegularExpressions.Regex.Replace(phone, @"[^\d]", "");
        if (onlyNumbers.Length < 10 || onlyNumbers.Length > 11)
            throw new InvalidOperationException("Telefone deve ter entre 10 e 11 dígitos.");
    }

    private static void ValidateDocumentNumber(string documentNumber)
    {
        if (string.IsNullOrWhiteSpace(documentNumber))
            throw new InvalidOperationException("Número do documento é obrigatório.");

        if (documentNumber.Length < 5 || documentNumber.Length > 20)
            throw new InvalidOperationException("Número do documento deve ter entre 5 e 20 caracteres.");
    }
}

/// <summary>
/// Evento de domínio disparado quando dados do paciente são anonimizados.
/// </summary>
public sealed class PatientDataAnonymizedEvent : DomainEvent
{
    /// <summary>
    /// ID do paciente anonimizado.
    /// </summary>
    public Guid PatientId { get; }

    /// <summary>
    /// Inicializa uma nova instância do evento.
    /// </summary>
    /// <param name="patientId">ID do paciente.</param>
    public PatientDataAnonymizedEvent(Guid patientId)
    {
        PatientId = patientId;
    }
}
