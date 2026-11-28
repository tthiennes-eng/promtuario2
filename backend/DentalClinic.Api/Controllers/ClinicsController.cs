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
    /// Lista clínicas (por padrão retorna todas para permitir reativação na gestão; passe onlyActive=true para filtrar).
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] bool onlyActive = false)
    {
        var clinics = await _repository.GetAllAsync(includeInactive: !onlyActive);
        var result = clinics.Select(MapClinic);
        return Ok(result);
    }

    private static ClinicResponse MapClinic(Clinic clinic) => new(
        clinic.Id,
        clinic.Name,
        clinic.Description,
        !string.IsNullOrWhiteSpace(clinic.Location) ? clinic.Location : (clinic.Address?.City == "." ? "" : clinic.Address?.City),
        clinic.MaxCapacity > 0 ? clinic.MaxCapacity : 1,
        clinic.IsActive,
        ParseHour(clinic.OpeningTime, 8),
        ParseHour(clinic.ClosingTime, 18),
        clinic.SlotDurationMinutes > 0 ? clinic.SlotDurationMinutes : 60);

    private static string? ValidateRequest(CreateClinicRequest request, out int startHour, out int endHour, out int slotDuration)
    {
        startHour = request.StartHour;
        endHour = request.EndHour;
        slotDuration = request.SlotDurationMinutes > 0 ? request.SlotDurationMinutes : 60;

        var trimmedName = request.Name?.Trim() ?? string.Empty;
        if (trimmedName.Length < 3 || trimmedName.Length > 100)
            return "Nome da clínica deve ter entre 3 e 100 caracteres.";

        if (startHour < 0 || startHour > 23 || endHour < 0 || endHour > 23)
            return "Horários de abertura e fechamento devem estar entre 0 e 23.";

        if (endHour <= startHour)
            return "O horário de fechamento deve ser posterior ao horário de abertura.";

        return null;
    }

    /// <summary>
    /// Cadastra uma nova clínica/departamento.
    /// </summary>
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateClinicRequest request)
    {
        var validationError = ValidateRequest(request, out var startHour, out var endHour, out var slotDuration);
        if (validationError != null) return BadRequest(new { message = validationError });

        try
        {
            if (Guid.TryParse(request.Id, out var existingId) && existingId != Guid.Empty)
            {
                var existing = await _repository.GetByIdAsync(existingId);
                if (existing != null)
                {
                    existing.UpdateBasic(
                        request.Name,
                        request.Description,
                        request.Capacity > 0 ? request.Capacity : 1,
                        startHour,
                        endHour,
                        request.IsActive,
                        request.Location,
                        slotDuration);
                    await _repository.UpdateAsync(existing);
                    return Ok(MapClinic(existing));
                }
            }

            var clinic = Clinic.CreateBasic(
                request.Name,
                request.Description ?? string.Empty,
                request.Capacity > 0 ? request.Capacity : 1,
                startHour,
                endHour,
                request.Location,
                slotDuration);

            if (Guid.TryParse(request.Id, out var parsedId) && parsedId != Guid.Empty)
                clinic.Id = parsedId;

            await _repository.AddAsync(clinic);
            return StatusCode(201, MapClinic(clinic));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Atualiza os dados de uma clínica.
    /// </summary>
    [HttpPut("{id}")]
    [Authorize(Roles = "Admin,Coordinator")]
    public async Task<IActionResult> Update(Guid id, [FromBody] CreateClinicRequest request)
    {
        var validationError = ValidateRequest(request, out var startHour, out var endHour, out var slotDuration);
        if (validationError != null) return BadRequest(new { message = validationError });

        var clinic = await _repository.GetByIdAsync(id);
        if (clinic == null) return NotFound();

        try
        {
            clinic.UpdateBasic(
                request.Name,
                request.Description,
                request.Capacity > 0 ? request.Capacity : 1,
                startHour,
                endHour,
                request.IsActive,
                request.Location,
                slotDuration);

            await _repository.UpdateAsync(clinic);
            return NoContent();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
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
