using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DentalClinic.Api.Controllers;

/// <summary>
/// Controller para gestão do catálogo de procedimentos da clínica escola.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ProceduresController : ControllerBase
{
    private readonly IProcedureRepository _repository;
    private readonly IClinicRepository _clinicRepository;

    public ProceduresController(IProcedureRepository repository, IClinicRepository clinicRepository)
    {
        _repository = repository;
        _clinicRepository = clinicRepository;
    }

    private static object MapProcedure(Procedure p) => new
    {
        id = p.Id,
        name = p.Name,
        code = p.Code,
        description = string.IsNullOrWhiteSpace(p.Code) ? null : p.Code,
        baseValue = p.BaseValue,
        basePrice = p.BaseValue,
        specialty = p.Specialty?.ToString(),
        category = p.Specialty?.ToString() ?? "Geral",
        estimatedTimeMinutes = p.EstimatedTimeMinutes
    };

    /// <summary>
    /// Lista todos os procedimentos disponíveis.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var procedures = await _repository.GetAllAsync();
        return Ok(procedures.Select(MapProcedure));
    }

    /// <summary>
    /// Lista procedimentos filtrados por especialidade.
    /// </summary>
    [HttpGet("specialty/{specialty}")]
    public async Task<IActionResult> GetBySpecialty(Specialty specialty)
    {
        var procedures = await _repository.GetBySpecialtyAsync(specialty);
        return Ok(procedures.Select(MapProcedure));
    }

    /// <summary>
    /// Lista procedimentos disponíveis para uma clínica.
    /// </summary>
    [HttpGet("clinic/{clinicId}")]
    public async Task<IActionResult> GetByClinic(Guid clinicId)
    {
        var clinic = await _clinicRepository.GetByIdAsync(clinicId);
        if (clinic != null && clinic.Specialty != Specialty.IntegratedClinic)
        {
            var bySpecialty = (await _repository.GetBySpecialtyAsync(clinic.Specialty)).ToList();
            if (bySpecialty.Count > 0)
            {
                return Ok(bySpecialty.Select(MapProcedure));
            }
        }

        var procedures = await _repository.GetAllAsync();
        return Ok(procedures.Select(MapProcedure));
    }

    /// <summary>
    /// Cadastra um novo procedimento no catálogo.
    /// </summary>
    [HttpPost]
    [Authorize(Roles = "Admin,Coordinator")]
    public async Task<IActionResult> Create([FromBody] CreateProcedureRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
            return BadRequest(new { message = "Nome do procedimento é obrigatório." });

        var specialty = Specialty.IntegratedClinic;
        if (!string.IsNullOrWhiteSpace(request.Specialty) &&
            Enum.TryParse<Specialty>(request.Specialty.Trim(), true, out var parsed) &&
            Enum.IsDefined(typeof(Specialty), parsed))
        {
            specialty = parsed;
        }
        else if (!string.IsNullOrWhiteSpace(request.Category) &&
                 Enum.TryParse<Specialty>(request.Category.Trim(), true, out var parsedCat) &&
                 Enum.IsDefined(typeof(Specialty), parsedCat))
        {
            specialty = parsedCat;
        }

        var procedure = Procedure.Create(
            request.Name.Trim(),
            (request.Code ?? request.Description ?? string.Empty).Trim(),
            request.BaseValue ?? request.BasePrice ?? 0m,
            specialty,
            request.EstimatedTimeMinutes > 0 ? request.EstimatedTimeMinutes : 60);

        await _repository.AddAsync(procedure);
        return CreatedAtAction(nameof(GetAll), new { id = procedure.Id }, MapProcedure(procedure));
    }
}

public record CreateProcedureRequest(
    string Name,
    string? Code = null,
    string? Description = null,
    decimal? BaseValue = null,
    decimal? BasePrice = null,
    string? Specialty = null,
    string? Category = null,
    int EstimatedTimeMinutes = 60);
