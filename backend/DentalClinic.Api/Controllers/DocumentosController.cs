using System.Security.Claims;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DentalClinic.Api.Controllers;

/// <summary>
/// Controller para emissão e histórico de documentos clínicos (receitas e atestados).
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class DocumentosController : ControllerBase
{
    private readonly IProntuarioRepository _prontuarioRepository;
    private readonly IClinicRepository _clinicRepository;
    private readonly ILogger<DocumentosController> _logger;

    public DocumentosController(
        IProntuarioRepository prontuarioRepository,
        IClinicRepository clinicRepository,
        ILogger<DocumentosController> logger)
    {
        _prontuarioRepository = prontuarioRepository;
        _clinicRepository = clinicRepository;
        _logger = logger;
    }

    private async Task<Guid> ResolveClinicIdAsync(Guid? requestedClinicId)
    {
        if (requestedClinicId.HasValue && requestedClinicId.Value != Guid.Empty)
        {
            var clinic = await _clinicRepository.GetByIdAsync(requestedClinicId.Value);
            if (clinic != null) return clinic.Id;
        }
        var first = (await _clinicRepository.GetAllAsync()).FirstOrDefault();
        return first?.Id ?? Guid.Empty;
    }

    [HttpPost("receitas")]
    [Authorize(Roles = "Admin,Coordinator,Professor")]
    public async Task<IActionResult> CreatePrescription([FromBody] CreatePrescriptionRequest request)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out var doctorId))
            return Unauthorized();

        if (request.PatientId == Guid.Empty)
            return BadRequest(new { message = "Paciente inválido." });
        var validItems = request.Items?
            .Where(i => !string.IsNullOrWhiteSpace(i.MedicineName))
            .ToList() ?? new List<PrescriptionItemDto>();
        if (validItems.Count == 0)
            return BadRequest(new { message = "Adicione pelo menos um medicamento válido à receita." });

        try
        {
            var clinicId = await ResolveClinicIdAsync(request.ClinicId);
            var prescription = Prescription.Create(request.PatientId, doctorId, clinicId, request.Observations);
            foreach (var item in validItems)
            {
                prescription.AddItem(
                    item.MedicineName.Trim(),
                    item.Dosage?.Trim() ?? string.Empty,
                    item.Instructions?.Trim() ?? string.Empty);
            }

            var created = await _prontuarioRepository.CreatePrescriptionAsync(prescription);
            return CreatedAtAction(nameof(GetPrescriptions), new { patientId = created.PatientId }, MapPrescription(created));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao emitir receita para o paciente {PatientId}", request.PatientId);
            return StatusCode(500, new { message = "Erro interno ao emitir receita." });
        }
    }

    [HttpGet("receitas/{patientId}")]
    public async Task<IActionResult> GetPrescriptions(Guid patientId)
    {
        var items = await _prontuarioRepository.GetPrescriptionHistoryAsync(patientId);
        return Ok(items.Select(MapPrescription));
    }

    [HttpPost("atestados")]
    [Authorize(Roles = "Admin,Coordinator,Professor")]
    public async Task<IActionResult> CreateCertificate([FromBody] CreateCertificateRequest request)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out var doctorId))
            return Unauthorized();

        if (request.PatientId == Guid.Empty)
            return BadRequest(new { message = "Paciente inválido." });
        if (string.IsNullOrWhiteSpace(request.Content))
            return BadRequest(new { message = "O conteúdo do atestado não pode ser vazio." });

        try
        {
            var clinicId = await ResolveClinicIdAsync(request.ClinicId);
            var certificate = MedicalCertificate.Create(
                request.PatientId,
                doctorId,
                clinicId,
                request.Content.Trim(),
                request.DaysOfRest < 0 ? 0 : request.DaysOfRest,
                request.Cid?.Trim() ?? string.Empty);

            var created = await _prontuarioRepository.CreateCertificateAsync(certificate);
            return CreatedAtAction(nameof(GetCertificates), new { patientId = created.PatientId }, MapCertificate(created));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao emitir atestado para o paciente {PatientId}", request.PatientId);
            return StatusCode(500, new { message = "Erro interno ao emitir atestado." });
        }
    }

    [HttpGet("atestados/{patientId}")]
    public async Task<IActionResult> GetCertificates(Guid patientId)
    {
        var items = await _prontuarioRepository.GetCertificateHistoryAsync(patientId);
        return Ok(items.Select(MapCertificate));
    }

    private static object MapPrescription(Prescription p) => new
    {
        id = p.Id,
        patientId = p.PatientId,
        clinicId = p.ClinicId,
        doctorId = p.DoctorId,
        doctorName = p.Doctor?.Name ?? "Profissional",
        observations = p.Observations,
        items = p.Items.Select(i => new
        {
            medicineName = i.MedicineName,
            dosage = i.Dosage,
            instructions = i.Instructions
        }),
        date = p.CreatedAt,
        createdAt = p.CreatedAt
    };

    private static object MapCertificate(MedicalCertificate c) => new
    {
        id = c.Id,
        patientId = c.PatientId,
        clinicId = c.ClinicId,
        doctorId = c.DoctorId,
        doctorName = c.Doctor?.Name ?? "Profissional",
        content = c.Content,
        daysOfRest = c.DaysOfRest,
        cid = c.CID,
        date = c.CreatedAt,
        createdAt = c.CreatedAt
    };
}

public record PrescriptionItemDto(string MedicineName, string? Dosage, string? Instructions);
public record CreatePrescriptionRequest(Guid PatientId, Guid? ClinicId, string? Observations, List<PrescriptionItemDto> Items);
public record CreateCertificateRequest(Guid PatientId, Guid? ClinicId, string Content, int DaysOfRest, string? Cid);
