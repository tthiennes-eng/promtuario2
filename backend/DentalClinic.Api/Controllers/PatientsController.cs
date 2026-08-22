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
        var patients = await _patientRepository.GetAllAsync(page, pageSize, searchTerm);
        var total = await _patientRepository.CountAsync(searchTerm);

        return Ok(new
        {
            Items = patients,
            Total = total,
            Page = page,
            PageSize = pageSize
        });
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var patient = await _patientRepository.GetByIdAsync(id);
        if (patient == null) return NotFound();
        return Ok(patient);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Patient patient)
    {
        try
        {
            await _patientRepository.AddAsync(patient);

            // Notifica em tempo real todos os terminais conectados na rede
            // local para que a lista de pacientes seja atualizada sem
            // depender de o usuário reabrir a tela manualmente.
            await _hubContext.Clients.All.SendAsync("PatientCreated", patient);

            return CreatedAtAction(nameof(GetById), new { id = patient.Id }, patient);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao criar paciente.");
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] Patient patient)
    {
        if (id != patient.Id) return BadRequest();
        var existing = await _patientRepository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        // Comparar campos e gerar log de alterações se houver mudanças
        var changes = new Dictionary<string, object>();
        
        if (existing.FullName != patient.FullName)
            changes["FullName"] = new { old = existing.FullName, @new = patient.FullName };
        
        if (existing.CPF != patient.CPF)
            changes["CPF"] = new { old = existing.CPF, @new = patient.CPF };
        
        if (existing.Email != patient.Email)
            changes["Email"] = new { old = existing.Email, @new = patient.Email };
        
        if (existing.Phone != patient.Phone)
            changes["Phone"] = new { old = existing.Phone, @new = patient.Phone };
        
        if (existing.BirthDate != patient.BirthDate)
            changes["BirthDate"] = new { old = existing.BirthDate, @new = patient.BirthDate };
        
        if (existing.Gender != patient.Gender)
            changes["Gender"] = new { old = existing.Gender, @new = patient.Gender };
        
        // Comparar endereço (objeto complexo)
        var existingAddressJson = JsonSerializer.Serialize(existing.Address);
        var newAddressJson = JsonSerializer.Serialize(patient.Address);
        if (existingAddressJson != newAddressJson)
            changes["Address"] = new { old = existing.Address, @new = patient.Address };
        
        if (existing.LgpdConsent != patient.LgpdConsent)
            changes["LgpdConsent"] = new { old = existing.LgpdConsent, @new = patient.LgpdConsent };
        
        if (existing.IsActive != patient.IsActive)
            changes["IsActive"] = new { old = existing.IsActive, @new = patient.IsActive };

        // Atualizar timestamp de modificação para sincronização
        patient.LastModifiedAt = DateTime.UtcNow;

        // Persistir alterações do paciente
        await _patientRepository.UpdateAsync(patient);

        // Se houver mudanças, criar log de alteração
        if (changes.Count > 0)
        {
            try
            {
                // Resolver usuário logado conforme padrão do AuditFilter
                var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                var userNameClaim = HttpContext.User.FindFirst(ClaimTypes.Name)?.Value 
                    ?? HttpContext.User.Identity?.Name 
                    ?? "Usuário Desconhecido";

                if (!string.IsNullOrEmpty(userIdClaim) && Guid.TryParse(userIdClaim, out var userId))
                {
                    var changeLog = new PatientChangeLog
                    {
                        PatientId = patient.Id,
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
                _logger.LogWarning(ex, "Falha ao criar log de alteração do paciente {PatientId}", patient.Id);
                // Não falha a operação principal se o log falhar
            }
        }

        // Notifica os demais terminais para que sincronizem o cache local.
        await _hubContext.Clients.All.SendAsync("PatientUpdated", patient);

        return NoContent();
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
        var patients = await _patientRepository.GetModifiedSinceAsync(since, page, pageSize);
        
        return Ok(new
        {
            Items = patients,
            Total = patients.Count(),
            Page = page,
            PageSize = pageSize,
            SyncedAt = DateTime.UtcNow
        });
    }
}
