using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
// Alias para resolver ambiguidade
using Specialty = DentalClinic.Core.Domain.Entities.Specialty;

namespace DentalClinic.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class WaitListController : ControllerBase
{
    private readonly IWaitListRepository _repository;
    private readonly IPatientRepository _patientRepository;
    private readonly IClinicRepository _clinicRepository;
    private readonly ILogger<WaitListController> _logger;

    public WaitListController(
        IWaitListRepository repository,
        IPatientRepository patientRepository,
        IClinicRepository clinicRepository,
        ILogger<WaitListController> logger)
    {
        _repository = repository;
        _patientRepository = patientRepository;
        _clinicRepository = clinicRepository;
        _logger = logger;
    }

    [HttpGet("clinic/{clinicId}")]
    public async Task<IActionResult> GetByClinic(Guid clinicId)
    {
        var entries = await _repository.GetActiveByClinicAsync(clinicId);
        return Ok(entries.Select(e => new
        {
            id = e.Id,
            patientId = e.PatientId,
            patientName = e.Patient?.FullName ?? "Paciente",
            clinicId = e.ClinicId,
            specialty = e.Specialty.ToString(),
            priority = e.Priority,
            observation = e.Observation,
            createdAt = e.CreatedAt
        }));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateWaitListRequest request)
    {
        if (request.PatientId == Guid.Empty || request.ClinicId == Guid.Empty)
            return BadRequest(new { message = "Paciente e clínica devem possuir IDs válidos." });

        var patient = await _patientRepository.GetByIdAsync(request.PatientId);
        if (patient == null)
            return BadRequest(new { message = "O paciente informado não existe." });

        var clinic = await _clinicRepository.GetByIdAsync(request.ClinicId);
        if (clinic == null)
            return BadRequest(new { message = "A clínica informada não existe." });

        var priority = string.IsNullOrWhiteSpace(request.Priority) ? "Normal" : request.Priority.Trim();
        if (priority.Length > 50)
            priority = priority[..50];

        var specialty = ParseSpecialty(request.Specialty);
        var entry = WaitListEntry.Create(
            request.PatientId,
            request.ClinicId,
            specialty,
            priority,
            request.Observation);

        await _repository.AddAsync(entry);
        return CreatedAtAction(nameof(GetByClinic), new { clinicId = entry.ClinicId }, new
        {
            id = entry.Id,
            patientId = entry.PatientId,
            patientName = patient.FullName,
            clinicId = entry.ClinicId,
            specialty = entry.Specialty.ToString(),
            priority = entry.Priority,
            observation = entry.Observation,
            createdAt = entry.CreatedAt
        });
    }

    [HttpPatch("{id}/resolve")]
    public async Task<IActionResult> Resolve(Guid id)
    {
        var entry = await _repository.GetByIdAsync(id);
        if (entry == null) return NotFound();

        entry.Resolve();
        await _repository.UpdateAsync(entry);
        return NoContent();
    }

    private static Specialty ParseSpecialty(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw)) return Specialty.IntegratedClinic;
        if (Enum.TryParse<Specialty>(raw.Trim(), true, out var parsed)) return parsed;
        return raw.Trim().ToLowerInvariant() switch
        {
            "endodontia" => Specialty.Endodontics,
            "periodontia" => Specialty.Periodontics,
            "protese" or "prótese" => Specialty.Prosthodontics,
            "cirurgia" => Specialty.Surgery,
            "ortodontia" => Specialty.Orthodontics,
            "odontopediatria" => Specialty.PediatricDentistry,
            "implantodontia" => Specialty.Implantology,
            "dentistica" or "dentística" => Specialty.RestorativeDentistry,
            _ => Specialty.IntegratedClinic
        };
    }
}

public record CreateWaitListRequest(
    Guid PatientId,
    Guid ClinicId,
    string? Specialty,
    string? Priority,
    string? Observation);
