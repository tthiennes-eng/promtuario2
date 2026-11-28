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
    private readonly ILogger<WaitListController> _logger;

    public WaitListController(IWaitListRepository repository, ILogger<WaitListController> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    [HttpGet("clinic/{clinicId}")]
    public async Task<IActionResult> GetByClinic(Guid clinicId)
    {
        var entries = await _repository.GetActiveByClinicAsync(clinicId);
        return Ok(entries);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateWaitListRequest request)
    {
        var specialty = ParseSpecialty(request.Specialty);
        var entry = WaitListEntry.Create(
            request.PatientId,
            request.ClinicId,
            specialty,
            string.IsNullOrWhiteSpace(request.Priority) ? "Normal" : request.Priority.Trim(),
            request.Observation);

        await _repository.AddAsync(entry);
        return CreatedAtAction(nameof(GetByClinic), new { clinicId = entry.ClinicId }, entry);
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
