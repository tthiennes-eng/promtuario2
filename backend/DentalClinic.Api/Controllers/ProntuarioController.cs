using System.Security.Claims;
using System.Text.Json;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DentalClinic.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ProntuarioController : ControllerBase
{
    private readonly IProntuarioRepository _prontuarioRepository;
    private readonly ITreatmentPlanRepository _treatmentPlanRepository;
    private readonly IAnexoRepository _anexoRepository;
    private readonly IAppointmentRepository _appointmentRepository;

    public ProntuarioController(
        IProntuarioRepository prontuarioRepository,
        ITreatmentPlanRepository treatmentPlanRepository,
        IAnexoRepository anexoRepository,
        IAppointmentRepository appointmentRepository)
    {
        _prontuarioRepository = prontuarioRepository;
        _treatmentPlanRepository = treatmentPlanRepository;
        _anexoRepository = anexoRepository;
        _appointmentRepository = appointmentRepository;
    }

    [HttpGet("{patientId}/odontogram")]
    public async Task<IActionResult> GetOdontogram(Guid patientId)
    {
        var odontogram = await _prontuarioRepository.GetOdontogramByPatientIdAsync(patientId);
        return Ok(odontogram);
    }

    [HttpPost("odontogram")]
    public async Task<IActionResult> SaveOdontogram([FromBody] SaveOdontogramRequest request)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        if (request.PatientId == Guid.Empty)
            return BadRequest(new { message = "Paciente inválido." });

        var teeth = new List<ToothCondition>();
        if (request.Teeth != null)
        {
            foreach (var item in request.Teeth)
            {
                var surfaces = new List<ToothSurface>();
                if (item.Surfaces != null)
                {
                    foreach (var s in item.Surfaces)
                    {
                        if (Enum.TryParse<ToothSurface>(s, true, out var parsedSurface))
                        {
                            surfaces.Add(parsedSurface);
                        }
                    }
                }

                if (!Enum.TryParse<ConditionType>(item.Condition, true, out var parsedCondition))
                {
                    parsedCondition = ConditionType.Healthy;
                }

                teeth.Add(new ToothCondition(item.ToothNumber, surfaces, parsedCondition, item.Observation));
            }
        }

        var odontogram = Odontogram.Create(request.PatientId, userId);
        odontogram.ReplaceTeeth(teeth, userId);
        await _prontuarioRepository.SaveOdontogramAsync(odontogram);

        return Ok(odontogram);
    }

    [HttpGet("{patientId}/anamnese")]
    public async Task<IActionResult> GetAnamnese(Guid patientId)
    {
        var anamnese = await _prontuarioRepository.GetAnamneseByPatientIdAsync(patientId);
        return Ok(anamnese);
    }

    [HttpPost("{patientId}/anamnese")]
    public async Task<IActionResult> SaveAnamnese(Guid patientId, [FromBody] JsonElement responses)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        var json = responses.GetRawText();
        var anamnese = Anamnese.Create(patientId, json, userId);
        await _prontuarioRepository.SaveAnamneseAsync(anamnese);
        await _prontuarioRepository.SaveClinicalSheetAsync(patientId, "anamnese", json, userId);
        return Ok();
    }

    [HttpGet("{patientId}/endodontia")]
    public async Task<IActionResult> GetEndodontia(Guid patientId)
    {
        var sheet = await _prontuarioRepository.GetLatestClinicalSheetAsync(patientId, "endodontia");
        if (sheet == null) return Ok(null);
        return Content(sheet.DataJson, "application/json");
    }

    [HttpPost("{patientId}/endodontia")]
    public async Task<IActionResult> SaveEndodontia(Guid patientId, [FromBody] JsonElement data)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        var saved = await _prontuarioRepository.SaveClinicalSheetAsync(patientId, "endodontia", data.GetRawText(), userId);
        return Ok(new { id = saved.Id, version = saved.Version, updatedAt = saved.CreatedAt });
    }

    [HttpGet("{patientId}/periograma")]
    public async Task<IActionResult> GetPeriograma(Guid patientId)
    {
        var sheet = await _prontuarioRepository.GetLatestClinicalSheetAsync(patientId, "periograma");
        if (sheet == null) return Ok(null);
        return Content(sheet.DataJson, "application/json");
    }

    [HttpPost("{patientId}/periograma")]
    public async Task<IActionResult> SavePeriograma(Guid patientId, [FromBody] JsonElement data)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        var saved = await _prontuarioRepository.SaveClinicalSheetAsync(patientId, "periograma", data.GetRawText(), userId);
        return Ok(new { id = saved.Id, version = saved.Version, updatedAt = saved.CreatedAt });
    }

    [HttpGet("{patientId}/fichas/{sheetType}")]
    public async Task<IActionResult> GetClinicalSheet(Guid patientId, string sheetType)
    {
        var sheet = await _prontuarioRepository.GetLatestClinicalSheetAsync(patientId, sheetType);
        if (sheet == null) return Ok(null);
        return Content(sheet.DataJson, "application/json");
    }

    [HttpPost("{patientId}/fichas/{sheetType}")]
    public async Task<IActionResult> SaveClinicalSheet(Guid patientId, string sheetType, [FromBody] JsonElement data)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        var rawJson = data.GetRawText();
        var saved = await _prontuarioRepository.SaveClinicalSheetAsync(patientId, sheetType, rawJson, userId);

        if (string.Equals(sheetType, "anamnese", StringComparison.OrdinalIgnoreCase))
        {
            try
            {
                var anamnese = Anamnese.Create(patientId, rawJson, userId);
                await _prontuarioRepository.SaveAnamneseAsync(anamnese);
            }
            catch
            {
                // Não bloqueia se a tabela legada anamneses não estiver presente
            }
        }

        return Ok(new
        {
            id = saved.Id,
            sheetType = saved.SheetType,
            version = saved.Version,
            createdAt = saved.CreatedAt
        });
    }

    [HttpGet("{patientId}/fichas/{sheetType}/history")]
    public async Task<IActionResult> GetClinicalSheetHistory(Guid patientId, string sheetType)
    {
        var versions = await _prontuarioRepository.GetClinicalSheetHistoryAsync(patientId, sheetType);
        return Ok(versions.Select(v => new
        {
            id = v.Id,
            sheetType = v.SheetType,
            version = v.Version,
            createdAt = v.CreatedAt,
            data = JsonSerializer.Deserialize<JsonElement>(v.DataJson)
        }));
    }

    [HttpGet("{patientId}/evolutions")]
    public async Task<IActionResult> GetEvolutions(Guid patientId)
    {
        var evolutions = await _prontuarioRepository.GetEvolutionHistoryAsync(patientId);
        return Ok(evolutions.Select(e => new
        {
            id = e.Id,
            patientId = e.PatientId,
            studentId = e.StudentId,
            studentName = e.Student?.Name ?? "Aluno",
            professorId = e.ProfessorId,
            professorName = e.Professor?.Name ?? "Professor",
            clinicId = e.ClinicId,
            clinicName = e.Clinic?.Name ?? "Clínica Geral",
            description = e.Description,
            isSignedByProfessor = e.IsSignedByProfessor,
            signedAt = e.SignedAt,
            createdAt = e.CreatedAt
        }));
    }

    [HttpGet("{patientId}/summary")]
    public async Task<IActionResult> GetSummary(Guid patientId)
    {
        var sheets = (await _prontuarioRepository.GetAllLatestClinicalSheetsAsync(patientId)).ToList();
        var odontogram = await _prontuarioRepository.GetOdontogramByPatientIdAsync(patientId);
        var evolutions = (await _prontuarioRepository.GetEvolutionHistoryAsync(patientId)).ToList();
        var prescriptions = (await _prontuarioRepository.GetPrescriptionHistoryAsync(patientId)).ToList();
        var certificates = (await _prontuarioRepository.GetCertificateHistoryAsync(patientId)).ToList();
        var attachments = (await _anexoRepository.GetByPacienteIdAsync(patientId)).ToList();
        var activePlan = await _treatmentPlanRepository.GetActivePlanByPatientIdAsync(patientId);

        var sheetMap = sheets.ToDictionary(
            s => s.SheetType,
            s => (object)new { version = s.Version, updatedAt = s.CreatedAt });

        return Ok(new
        {
            sheets = sheetMap,
            odontogramTeethCount = odontogram?.Teeth.Count ?? 0,
            odontogramUpdatedAt = odontogram?.UpdatedAt ?? odontogram?.CreatedAt,
            evolutionsCount = evolutions.Count,
            pendingSignaturesCount = evolutions.Count(e => !e.IsSignedByProfessor),
            prescriptionsCount = prescriptions.Count,
            certificatesCount = certificates.Count,
            attachmentsCount = attachments.Count,
            treatmentPlanTotalItems = activePlan?.Items.Count ?? 0,
            treatmentPlanCompletedItems = activePlan?.Items.Count(i => i.Status == TreatmentItemStatus.Completed) ?? 0,
            treatmentPlanStatus = activePlan?.Status.ToString()
        });
    }

    [HttpGet("{patientId}/timeline")]
    public async Task<IActionResult> GetTimeline(Guid patientId)
    {
        var items = new List<TimelineEventDto>();

        var evolutions = await _prontuarioRepository.GetEvolutionHistoryAsync(patientId);
        foreach (var e in evolutions)
        {
            items.Add(new TimelineEventDto(
                e.Id.ToString(),
                "evolution",
                $"Evolução Clínica ({e.Clinic?.Name ?? "Clínica Geral"})",
                e.Description,
                e.CreatedAt,
                e.IsSignedByProfessor ? "Assinada" : "Pendente de assinatura",
                $"Aluno: {e.Student?.Name ?? "Não inf."} • Prof: {e.Professor?.Name ?? "Não inf."}"));
        }

        var prescriptions = await _prontuarioRepository.GetPrescriptionHistoryAsync(patientId);
        foreach (var p in prescriptions)
        {
            var meds = string.Join(", ", p.Items.Select(i => i.MedicineName));
            items.Add(new TimelineEventDto(
                p.Id.ToString(),
                "prescription",
                "Receita Emitida",
                string.IsNullOrWhiteSpace(meds) ? (p.Observations ?? "Receita odontológica") : meds,
                p.CreatedAt,
                $"{p.Items.Count} item(ns)",
                $"Profissional: {p.Doctor?.Name ?? "Não inf."}"));
        }

        var certificates = await _prontuarioRepository.GetCertificateHistoryAsync(patientId);
        foreach (var c in certificates)
        {
            items.Add(new TimelineEventDto(
                c.Id.ToString(),
                "certificate",
                $"Atestado ({c.DaysOfRest} dia(s))",
                c.Content,
                c.CreatedAt,
                string.IsNullOrWhiteSpace(c.CID) ? "Sem CID" : $"CID {c.CID}",
                $"Profissional: {c.Doctor?.Name ?? "Não inf."}"));
        }

        var attachments = await _anexoRepository.GetByPacienteIdAsync(patientId);
        foreach (var a in attachments)
        {
            items.Add(new TimelineEventDto(
                a.Id.ToString(),
                "exam",
                $"Exame / Anexo ({a.Tipo})",
                a.Nome,
                a.CreatedAt,
                a.Tipo,
                null));
        }

        var sheetVersions = await _prontuarioRepository.GetAllClinicalSheetVersionsAsync(patientId);
        foreach (var s in sheetVersions)
        {
            var label = s.SheetType switch
            {
                "anamnese" => "Anamnese",
                "extraoral" => "Exame Extraoral",
                "intraoral" => "Exame Intraoral",
                "periograma" => "Periograma",
                "endodontia" => "Endodontia",
                "ppr" => "Ficha PPR",
                "dtm" => "Ficha DTM",
                "tcle" => "Termo de Consentimento (TCLE)",
                _ => s.SheetType.ToUpperInvariant()
            };
            items.Add(new TimelineEventDto(
                s.Id.ToString(),
                "sheet",
                $"{label} (v{s.Version})",
                $"Ficha clínica registrada na versão {s.Version}.",
                s.CreatedAt,
                $"v{s.Version}",
                s.SheetType));
        }

        var appointments = (await _appointmentRepository.GetByRangeAsync(
            DateTime.UtcNow.AddYears(-5),
            DateTime.UtcNow.AddYears(2),
            null)).Where(a => a.PatientId == patientId);
        foreach (var a in appointments)
        {
            items.Add(new TimelineEventDto(
                a.Id.ToString(),
                "appointment",
                $"Agendamento: {a.ProcedureName ?? "Avaliação"}",
                a.Notes ?? "Consulta agendada",
                a.StartTime,
                a.Status.ToString(),
                a.StudentName != null ? $"Dupla: {a.StudentName}" : null));
        }

        return Ok(items.OrderByDescending(i => i.Date));
    }
}

public record OdontogramToothDto(int ToothNumber, List<string>? Surfaces, string Condition, string? Observation);
public record SaveOdontogramRequest(Guid PatientId, List<OdontogramToothDto>? Teeth);
public record TimelineEventDto(
    string Id,
    string Category,
    string Title,
    string Description,
    DateTime Date,
    string? Badge,
    string? Metadata);
