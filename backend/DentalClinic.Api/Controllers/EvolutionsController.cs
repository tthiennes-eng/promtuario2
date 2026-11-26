using System.Security.Claims;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DentalClinic.Api.Controllers;

/// <summary>
/// Controller para registro e assinatura digital de evoluções clínicas no prontuário.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class EvolutionsController : ControllerBase
{
    private readonly IProntuarioRepository _prontuarioRepository;
    private readonly ILogger<EvolutionsController> _logger;

    public EvolutionsController(IProntuarioRepository prontuarioRepository, ILogger<EvolutionsController> logger)
    {
        _prontuarioRepository = prontuarioRepository;
        _logger = logger;
    }

    /// <summary>
    /// Adiciona uma nova evolução ao prontuário do paciente.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateEvolutionRequest request)
    {
        var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(currentUserId) || !Guid.TryParse(currentUserId, out var studentId))
            return Unauthorized();

        if (request.PatientId == Guid.Empty)
            return BadRequest(new { message = "Paciente inválido." });
        if (string.IsNullOrWhiteSpace(request.Description))
            return BadRequest(new { message = "A descrição da evolução não pode ser vazia." });

        try
        {
            var created = await _prontuarioRepository.AddEvolutionAsync(
                request.PatientId,
                request.Description.Trim(),
                request.ProfessorId ?? Guid.Empty,
                studentId,
                request.ClinicId);

            return Ok(new
            {
                id = created.Id,
                patientId = created.PatientId,
                studentId = created.StudentId,
                studentName = created.Student?.Name ?? "Aluno",
                professorId = created.ProfessorId,
                professorName = created.Professor?.Name ?? "Professor",
                clinicId = created.ClinicId,
                clinicName = created.Clinic?.Name ?? "Clínica Geral",
                description = created.Description,
                isSignedByProfessor = created.IsSignedByProfessor,
                signedAt = created.SignedAt,
                createdAt = created.CreatedAt
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao registrar evolução clínica.");
            return BadRequest(new { message = ex.InnerException?.Message ?? ex.Message });
        }
    }

    /// <summary>
    /// Assina digitalmente uma evolução (Ação exclusiva do Professor/Admin/Coordenador).
    /// </summary>
    [HttpPost("{id}/sign")]
    [Authorize(Roles = "Professor,Admin,Coordinator")]
    public async Task<IActionResult> Sign(Guid id)
    {
        var signerIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(signerIdStr) || !Guid.TryParse(signerIdStr, out var signerId))
            return Unauthorized();

        var evolution = await _prontuarioRepository.GetEvolutionByIdAsync(id);
        if (evolution == null) return NotFound(new { message = "Evolução não encontrada." });

        var isAdminOrCoord = User.IsInRole("Admin") || User.IsInRole("Coordinator");
        try
        {
            evolution.Sign(signerId, allowOverride: isAdminOrCoord || User.IsInRole("Professor"));
            await _prontuarioRepository.UpdateEvolutionAsync(evolution);
            return Ok(new
            {
                id = evolution.Id,
                isSignedByProfessor = evolution.IsSignedByProfessor,
                signedAt = evolution.SignedAt,
                message = "Evolução assinada com sucesso."
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}

public record CreateEvolutionRequest(Guid PatientId, string Description, Guid? ProfessorId, Guid? ClinicId);
