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
        var entry = WaitListEntry.Create(
            request.PatientId,
            request.ClinicId,
            request.Specialty,
            request.Priority,
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
}

public record CreateWaitListRequest(
    Guid PatientId,
    Guid ClinicId,
    Specialty Specialty,
    string Priority,
    string? Observation);
