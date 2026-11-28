using System.Security.Claims;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DentalClinic.Api.Controllers;

/// <summary>
/// Controller para gestão dos Planos de Tratamento dos pacientes.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class TreatmentPlansController : ControllerBase
{
    private readonly ITreatmentPlanRepository _repository;
    private readonly ILogger<TreatmentPlansController> _logger;

    public TreatmentPlansController(ITreatmentPlanRepository repository, ILogger<TreatmentPlansController> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    /// <summary>
    /// Obtém o plano de tratamento ativo de um paciente.
    /// </summary>
    [HttpGet("active/{patientId}")]
    public async Task<IActionResult> GetActive(Guid patientId)
    {
        var plan = await _repository.GetActivePlanByPatientIdAsync(patientId);
        if (plan == null) return NotFound();
        return Ok(plan);
    }

    /// <summary>
    /// Cria um novo plano de tratamento ou adiciona itens ao plano ativo existente.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateTreatmentPlanRequest request)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        var existing = await _repository.GetActivePlanByPatientIdAsync(request.PatientId);
        if (existing != null)
        {
            if (request.Items != null && request.Items.Count > 0)
            {
                var existingKeys = existing.Items
                    .Select(i => $"{i.ProcedureName}|{i.ToothNumber}|{i.Observation}")
                    .ToHashSet(StringComparer.OrdinalIgnoreCase);

                foreach (var item in request.Items)
                {
                    var key = $"{item.ProcedureName}|{item.ToothNumber}|{item.Observation}";
                    if (!existingKeys.Contains(key))
                    {
                        var procId = item.ProcedureId == Guid.Empty ? Guid.NewGuid() : item.ProcedureId;
                        existing.AddItem(procId, item.ProcedureName, item.Value ?? 0, item.ToothNumber, item.Observation);
                        existingKeys.Add(key);
                    }
                }
                await _repository.UpdateAsync(existing);
            }
            return Ok(existing);
        }

        var plan = TreatmentPlan.Create(request.PatientId, userId, request.Description ?? "Plano de tratamento");
        if (request.Items != null)
        {
            foreach (var item in request.Items)
            {
                var procId = item.ProcedureId == Guid.Empty ? Guid.NewGuid() : item.ProcedureId;
                plan.AddItem(procId, item.ProcedureName, item.Value ?? 0, item.ToothNumber, item.Observation);
            }
        }
        await _repository.AddAsync(plan);

        return CreatedAtAction(nameof(GetActive), new { patientId = plan.PatientId }, plan);
    }

    /// <summary>
    /// Adiciona um item ao plano de tratamento.
    /// </summary>
    [HttpPost("{id}/items")]
    public async Task<IActionResult> AddItem(Guid id, [FromBody] AddTreatmentItemRequest request)
    {
        var plan = await _repository.GetByIdAsync(id);
        if (plan == null) return NotFound();

        var procId = request.ProcedureId == Guid.Empty ? Guid.NewGuid() : request.ProcedureId;
        plan.AddItem(procId, request.ProcedureName, request.Value ?? 0, request.ToothNumber, request.Observation);
        await _repository.UpdateAsync(plan);

        return Ok(plan);
    }

    /// <summary>
    /// Atualiza o status de um procedimento individual do plano de tratamento.
    /// </summary>
    [HttpPatch("{planId}/items/{itemId}/status")]
    public async Task<IActionResult> UpdateItemStatus(Guid planId, Guid itemId, [FromBody] UpdateTreatmentItemStatusRequest request)
    {
        var plan = await _repository.GetByIdAsync(planId);
        if (plan == null) return NotFound(new { message = "Plano de tratamento não encontrado." });

        var raw = request.Status?.Trim() ?? string.Empty;
        TreatmentItemStatus parsedStatus;
        if (string.Equals(raw, "canceled", StringComparison.OrdinalIgnoreCase))
        {
            parsedStatus = TreatmentItemStatus.Cancelled;
        }
        else if (!Enum.TryParse(raw, true, out parsedStatus) || !Enum.IsDefined(typeof(TreatmentItemStatus), parsedStatus))
        {
            return BadRequest(new { message = $"Status inválido: {request.Status}" });
        }

        if (!plan.UpdateItemStatus(itemId, parsedStatus))
            return NotFound(new { message = "Item não encontrado no plano." });

        await _repository.UpdateAsync(plan);
        return Ok(plan);
    }

    /// <summary>
    /// Remove um item do plano de tratamento.
    /// </summary>
    [HttpDelete("{planId}/items/{itemId}")]
    public async Task<IActionResult> DeleteItem(Guid planId, Guid itemId)
    {
        var plan = await _repository.GetByIdAsync(planId);
        if (plan == null) return NotFound();

        if (!plan.RemoveItem(itemId)) return NotFound();

        await _repository.UpdateAsync(plan);
        return Ok(plan);
    }

    /// <summary>
    /// Aprova o plano de tratamento (Ação do Professor/Responsável).
    /// </summary>
    [HttpPatch("{id}/approve")]
    [Authorize(Roles = "Professor,Admin,Coordinator")]
    public async Task<IActionResult> Approve(Guid id)
    {
        var plan = await _repository.GetByIdAsync(id);
        if (plan == null) return NotFound();

        if (plan.Status == TreatmentPlanStatus.Completed || plan.Status == TreatmentPlanStatus.Cancelled)
            return BadRequest(new { message = "Não é possível aprovar um plano já concluído ou cancelado." });

        plan.Approve();
        await _repository.UpdateAsync(plan);

        return Ok(plan);
    }
}

public record TreatmentPlanItemInput(Guid ProcedureId, string ProcedureName, decimal? Value, int? ToothNumber, string? Observation);
public record CreateTreatmentPlanRequest(Guid PatientId, string? Description, List<TreatmentPlanItemInput>? Items);
public record AddTreatmentItemRequest(Guid ProcedureId, string ProcedureName, decimal? Value, int? ToothNumber, string? Observation);
public record UpdateTreatmentItemStatusRequest(string Status);
