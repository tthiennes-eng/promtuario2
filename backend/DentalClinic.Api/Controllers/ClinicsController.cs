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

        var clinic = Clinic.CreateBasic(
            request.Name,
            request.Description ?? string.Empty,
            request.Capacity > 0 ? request.Capacity : 1,
            request.StartHour,
            request.EndHour);

        if (request.Id != Guid.Empty) clinic.Id = request.Id;
        await _repository.AddAsync(clinic);
        return StatusCode(201, new ClinicResponse(clinic.Id, clinic.Name, clinic.Description, request.Location,
            clinic.MaxCapacity, clinic.IsActive, request.StartHour, request.EndHour, request.SlotDurationMinutes));
    }

    /// <summary>
    /// Atualiza os dados de uma clínica.
    /// </summary>
    [HttpPut("{id}")]
    [Authorize(Roles = "Admin,Coordinator")]
    public async Task<IActionResult> Update(Guid id, [FromBody] Clinic clinic)
    {
        if (id != clinic.Id) return BadRequest();
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
    Guid Id,
    string Name,
    string? Description,
    string? Location,
    int Capacity,
    bool IsActive,
    int StartHour,
    int EndHour,
    int SlotDurationMinutes);

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
