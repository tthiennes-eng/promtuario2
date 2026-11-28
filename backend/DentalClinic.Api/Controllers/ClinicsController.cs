using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DentalClinic.Api.Controllers;

/// <summary>
/// Controller para gestão das clínicas e especialidades da universidade.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ClinicsController : ControllerBase
{
    private readonly IClinicRepository _repository;

    public ClinicsController(IClinicRepository repository)
    {
        _repository = repository;
    }

    /// <summary>
    /// Lista todas as clínicas ativas.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var clinics = await _repository.GetAllAsync();
        var result = clinics.Select(clinic => new ClinicResponse(
            clinic.Id,
            clinic.Name,
            clinic.Description,
            clinic.Address?.City,
            clinic.MaxCapacity,
            clinic.IsActive,
            ParseHour(clinic.OpeningTime, 8),
            ParseHour(clinic.ClosingTime, 18),
            60));
        return Ok(result);
    }

    /// <summary>
    /// Cadastra uma nova clínica/departamento.
    /// </summary>
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateClinicRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name)) return BadRequest("Nome da clínica é obrigatório.");

        if (Guid.TryParse(request.Id, out var existingId) && existingId != Guid.Empty)
        {
            var existing = await _repository.GetByIdAsync(existingId);
            if (existing != null)
            {
                existing.UpdateBasic(
                    request.Name,
                    request.Description,
                    request.Capacity > 0 ? request.Capacity : 1,
                    request.StartHour > 0 ? request.StartHour : 8,
                    request.EndHour > request.StartHour ? request.EndHour : 18,
                    request.IsActive,
                    request.Location);
                await _repository.UpdateAsync(existing);
                return Ok(new ClinicResponse(existing.Id, existing.Name, existing.Description, request.Location,
                    existing.MaxCapacity, existing.IsActive, request.StartHour, request.EndHour, request.SlotDurationMinutes));
            }
        }

        var startHour = request.StartHour > 0 ? request.StartHour : 8;
        var endHour = request.EndHour > startHour ? request.EndHour : 18;
        var clinic = Clinic.CreateBasic(
            request.Name,
            request.Description ?? string.Empty,
            request.Capacity > 0 ? request.Capacity : 1,
            startHour,
            endHour,
            request.Location);

        if (Guid.TryParse(request.Id, out var parsedId) && parsedId != Guid.Empty)
            clinic.Id = parsedId;

        await _repository.AddAsync(clinic);
        return StatusCode(201, new ClinicResponse(clinic.Id, clinic.Name, clinic.Description, request.Location,
            clinic.MaxCapacity, clinic.IsActive, startHour, endHour, request.SlotDurationMinutes > 0 ? request.SlotDurationMinutes : 60));
    }

    /// <summary>
    /// Atualiza os dados de uma clínica.
    /// </summary>
    [HttpPut("{id}")]
    [Authorize(Roles = "Admin,Coordinator")]
    public async Task<IActionResult> Update(Guid id, [FromBody] CreateClinicRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name)) return BadRequest("Nome da clínica é obrigatório.");

        var clinic = await _repository.GetByIdAsync(id);
        if (clinic == null) return NotFound();

        var startHour = request.StartHour > 0 ? request.StartHour : 8;
        var endHour = request.EndHour > startHour ? request.EndHour : 18;
        clinic.UpdateBasic(
            request.Name,
            request.Description,
            request.Capacity > 0 ? request.Capacity : 1,
            startHour,
            endHour,
            request.IsActive,
            request.Location);

        await _repository.UpdateAsync(clinic);
        return NoContent();
    }

    private static int ParseHour(string? time, int fallback)
    {
        if (TimeSpan.TryParse(time, out var parsed)) return parsed.Hours;
        return fallback;
    }
}

public record CreateClinicRequest(
    string? Id,
    string Name,
    string? Description,
    string? Location,
    int Capacity = 1,
    bool IsActive = true,
    int StartHour = 8,
    int EndHour = 18,
    int SlotDurationMinutes = 60);

public record ClinicResponse(
    Guid Id,
    string Name,
    string Description,
    string? Location,
    int Capacity,
    bool IsActive,
    int StartHour,
    int EndHour,
    int SlotDurationMinutes);
