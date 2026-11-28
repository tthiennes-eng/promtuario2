using DentalClinic.Api.Hubs;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;
using System.Text.Json;

namespace DentalClinic.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class PatientsController : ControllerBase
{
    private readonly IPatientRepository _patientRepository;
    private readonly IPatientChangeLogRepository _patientChangeLogRepository;
    private readonly ILogger<PatientsController> _logger;
    private readonly IHubContext<ClinicHub> _hubContext;

    public PatientsController(
        IPatientRepository patientRepository,
        IPatientChangeLogRepository patientChangeLogRepository,
        ILogger<PatientsController> logger,
        IHubContext<ClinicHub> hubContext)
    {
        _patientRepository = patientRepository;
        _patientChangeLogRepository = patientChangeLogRepository;
        _logger = logger;
        _hubContext = hubContext;
    }

    [HttpGet]
    public async Task<IActionResult> Get(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery(Name = "search")] string? searchTerm = null) // Sincronizado com Flutter
    {
        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 200);

        var patients = await _patientRepository.GetAllAsync(safePage, safePageSize, searchTerm);
        var total = await _patientRepository.CountAsync(searchTerm);

        return Ok(new
        {
            Items = patients,
            Total = total,
            Page = safePage,
            PageSize = safePageSize
        });
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var patient = await _patientRepository.GetByIdAsync(id);
        if (patient == null) return NotFound();
        return Ok(patient);
    }

    private static DateTime NormalizeUtc(DateTime value) =>
        value.Kind == DateTimeKind.Utc
            ? value
            : value.Kind == DateTimeKind.Local
                ? value.ToUniversalTime()
                : DateTime.SpecifyKind(value, DateTimeKind.Utc);

    private static string? ValidatePatient(Patient patient)
    {
        if (string.IsNullOrWhiteSpace(patient.FullName) || patient.FullName.Trim().Length < 2)
            return "Nome completo deve ter pelo menos 2 caracteres.";

        var cpfDigits = new string((patient.CPF ?? string.Empty).Where(char.IsDigit).ToArray());
        if (cpfDigits.Length != 11)
            return "CPF inválido. Informe exatamente 11 dígitos.";

        if (!string.IsNullOrWhiteSpace(patient.SusNumber))
        {
            var susDigits = new string(patient.SusNumber.Where(char.IsDigit).ToArray());
            if (susDigits.Length != 15)
                return "Número do Cartão SUS inválido. Deve conter 15 dígitos.";
            patient.SusNumber = susDigits;
        }

        if (NormalizeUtc(patient.BirthDate) > DateTime.UtcNow.AddDays(1))
            return "A data de nascimento não pode ser no futuro.";

        patient.FullName = patient.FullName.Trim();
        patient.CPF = cpfDigits;
        patient.SocialName = string.IsNullOrWhiteSpace(patient.SocialName) ? null : patient.SocialName.Trim();
        patient.Email = string.IsNullOrWhiteSpace(patient.Email) ? null : patient.Email.Trim();
        patient.Phone = string.IsNullOrWhiteSpace(patient.Phone) ? null : patient.Phone.Trim();
        return null;
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Patient patient)
    {
        var validationError = ValidatePatient(patient);
        if (validationError != null)
            return BadRequest(new { message = validationError });

        // Previne overposting de coleções de navegação enviadas no payload JSON
        patient.Appointments?.Clear();
        patient.Evolutions?.Clear();
        patient.Anexos?.Clear();

        try
        {
            patient.BirthDate = NormalizeUtc(patient.BirthDate);
            patient.CreatedAt = patient.CreatedAt == default ? DateTime.UtcNow : NormalizeUtc(patient.CreatedAt);
            patient.LastModifiedAt = DateTime.UtcNow;

            await _patientRepository.AddAsync(patient);

            try
            {
                await _hubContext.Clients.All.SendAsync("PatientCreated", new { id = patient.Id });
            }
            catch (Exception hubEx)
            {
                _logger.LogWarning(hubEx, "Paciente {PatientId} criado, mas falhou a notificação SignalR.", patient.Id);
            }

            return CreatedAtAction(nameof(GetById), new { id = patient.Id }, patient);
        }
        catch (Exception ex)
        {
            var root = ex;
            while (root.InnerException != null)
            {
                root = root.InnerException;
            }

            _logger.LogError(ex, "Erro ao criar paciente: {RootMessage}", root.Message);

            var rootMsg = root.Message;
            if (rootMsg.Contains("23505", StringComparison.OrdinalIgnoreCase) &&
                rootMsg.Contains("cpf", StringComparison.OrdinalIgnoreCase))
            {
                return Conflict(new { message = "Já existe um paciente cadastrado com este CPF." });
            }

            return BadRequest(new { message = "Não foi possível cadastrar o paciente. Verifique os dados informados." });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] Patient patient)
    {
        if (id != patient.Id) return BadRequest();

        var validationError = ValidatePatient(patient);
        if (validationError != null)
            return BadRequest(new { message = validationError });

        var existing = await _patientRepository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        var normalizedBirthDate = NormalizeUtc(patient.BirthDate);

        // Comparar campos e gerar log de alterações se houver mudanças
        var changes = new Dictionary<string, object>();

        if (existing.FullName != patient.FullName)
            changes["FullName"] = new { old = existing.FullName, @new = patient.FullName };

        if (existing.SocialName != patient.SocialName)
            changes["SocialName"] = new { old = existing.SocialName, @new = patient.SocialName };

        if (existing.CPF != patient.CPF)
            changes["CPF"] = new { old = existing.CPF, @new = patient.CPF };

        if (existing.SusNumber != patient.SusNumber)
            changes["SusNumber"] = new { old = existing.SusNumber, @new = patient.SusNumber };

        if (existing.Email != patient.Email)
            changes["Email"] = new { old = existing.Email, @new = patient.Email };

        if (existing.Phone != patient.Phone)
            changes["Phone"] = new { old = existing.Phone, @new = patient.Phone };

        if (existing.BirthDate != normalizedBirthDate)
            changes["BirthDate"] = new { old = existing.BirthDate, @new = normalizedBirthDate };

        if (existing.Gender != patient.Gender)
            changes["Gender"] = new { old = existing.Gender, @new = patient.Gender };

        // Só registra e aplica alteração de endereço quando o payload inclui Address
        if (patient.Address != null)
        {
            var existingAddressJson = JsonSerializer.Serialize(existing.Address);
            var newAddressJson = JsonSerializer.Serialize(patient.Address);
            if (existingAddressJson != newAddressJson)
                changes["Address"] = new { old = existing.Address, @new = patient.Address };
        }

        if (existing.LgpdConsent != patient.LgpdConsent)
            changes["LgpdConsent"] = new { old = existing.LgpdConsent, @new = patient.LgpdConsent };

        if (existing.IsActive != patient.IsActive)
            changes["IsActive"] = new { old = existing.IsActive, @new = patient.IsActive };

        // Atualizar campos no registro já rastreado pelo EF Core para evitar conflito de tracking
        existing.FullName = patient.FullName;
        existing.SocialName = patient.SocialName;
        existing.CPF = patient.CPF;
        existing.SusNumber = patient.SusNumber;
        existing.Email = patient.Email;
        existing.Phone = patient.Phone;
        existing.BirthDate = normalizedBirthDate;
        existing.Gender = patient.Gender;
        if (patient.Address != null)
        {
            existing.Address = patient.Address;
        }
        existing.LgpdConsent = patient.LgpdConsent;
        existing.IsActive = patient.IsActive;
        existing.LastModifiedAt = DateTime.UtcNow;

        try
        {
            await _patientRepository.UpdateAsync(existing);
        }
        catch (Exception ex)
        {
            var root = ex;
            while (root.InnerException != null) root = root.InnerException;
            if (root.Message.Contains("23505", StringComparison.OrdinalIgnoreCase) &&
                root.Message.Contains("cpf", StringComparison.OrdinalIgnoreCase))
            {
                return Conflict(new { message = "Já existe outro paciente cadastrado com este CPF." });
            }
            _logger.LogError(ex, "Erro ao atualizar paciente {PatientId}", id);
            return BadRequest(new { message = "Não foi possível atualizar os dados do paciente." });
        }

        // Se houver mudanças, criar log de alteração
        if (changes.Count > 0)
        {
            try
            {
                var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                var userNameClaim = HttpContext.User.FindFirst(ClaimTypes.Name)?.Value
                    ?? HttpContext.User.Identity?.Name
                    ?? "Usuário Desconhecido";

                if (!string.IsNullOrEmpty(userIdClaim) && Guid.TryParse(userIdClaim, out var userId))
                {
                    var changeLog = new PatientChangeLog
                    {
                        PatientId = existing.Id,
                        UserId = userId,
                        UserName = userNameClaim,
                        Timestamp = DateTime.UtcNow,
                        ChangesJson = JsonSerializer.Serialize(changes)
                    };

                    await _patientChangeLogRepository.CreateAsync(changeLog);
                    await _patientChangeLogRepository.SaveChangesAsync();
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Falha ao criar log de alteração do paciente {PatientId}", existing.Id);
            }
        }

        try
        {
            await _hubContext.Clients.All.SendAsync("PatientUpdated", new { id = existing.Id });
        }
        catch (Exception hubEx)
        {
            _logger.LogWarning(hubEx, "Paciente {PatientId} atualizado, mas falhou a notificação SignalR.", existing.Id);
        }

        return NoContent();
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin,Coordinator")]
    public async Task<IActionResult> Delete(Guid id)
    {
        try
        {
            var existing = await _patientRepository.GetByIdAsync(id);
            if (existing == null) return NotFound();

            await _patientRepository.DeleteAsync(id);

            try
            {
                await _hubContext.Clients.All.SendAsync("PatientDeleted", id);
            }
            catch (Exception hubEx)
            {
                _logger.LogWarning(hubEx, "Paciente {PatientId} excluído, mas falhou a notificação SignalR.", id);
            }

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao excluir paciente {PatientId}", id);
            return StatusCode(500, new
            {
                message = "Erro interno ao excluir paciente."
            });
        }
    }

    /// <summary>
    /// Retorna o histórico de alterações de um paciente específico.
    /// </summary>
    [HttpGet("{id}/history")]
    public async Task<IActionResult> GetHistory(Guid id)
    {
        var logs = await _patientChangeLogRepository.GetByPatientIdAsync(id);

        // Retorna no formato esperado pelo Flutter:
        // id, patientId, userId, userName, timestamp, changesJson
        return Ok(logs.Select(l => new
        {
            id = l.Id.ToString(),
            patientId = l.PatientId.ToString(),
            userId = l.UserId.ToString(),
            userName = l.UserName,
            timestamp = l.Timestamp,
            changesJson = l.ChangesJson
        }));
    }

    /// <summary>
    /// Endpoint para sincronização de pacientes entre dispositivos.
    /// Retorna todos os pacientes modificados após a data informada.
    /// </summary>
    /// <param name="since">Data da última sincronização (UTC)</param>
    /// <param name="page">Página (padrão: 1)</param>
    /// <param name="pageSize">Tamanho da página (padrão: 50)</param>
    [HttpGet("sync")]
    public async Task<IActionResult> Sync(
        [FromQuery] DateTime since,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 200);
        var sinceUtc = NormalizeUtc(since);
        var patients = await _patientRepository.GetModifiedSinceAsync(sinceUtc, safePage, safePageSize);
        var total = await _patientRepository.CountModifiedSinceAsync(sinceUtc);

        return Ok(new
        {
            Items = patients,
            Total = total,
            Page = safePage,
            PageSize = safePageSize,
            SyncedAt = DateTime.UtcNow
        });
    }
}
