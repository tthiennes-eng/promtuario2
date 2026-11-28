using System.Security.Claims;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DentalClinic.Api.Controllers;

/// <summary>
/// Controller para visualização de logs de auditoria e conformidade LGPD.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class LogsController : ControllerBase
{
    private readonly ILogAuditoriaRepository _repository;
    private readonly ILogger<LogsController> _logger;

    public LogsController(ILogAuditoriaRepository repository, ILogger<LogsController> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    /// <summary>
    /// Lista os logs de auditoria de forma paginada (restrito a Administradores).
    /// </summary>
    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Get(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50,
        [FromQuery] Guid? userId = null,
        [FromQuery] string? action = null,
        [FromQuery] string? resourceId = null)
    {
        try
        {
            var safePage = Math.Max(1, page);
            var safePageSize = Math.Clamp(pageSize, 1, 200);
            var (items, total) = await _repository.GetPagedAsync(safePage, safePageSize, userId, action, resourceId);

            return Ok(new
            {
                Items = items,
                Total = total,
                Page = safePage,
                PageSize = safePageSize
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao recuperar logs de auditoria.");
            return StatusCode(500, "Erro interno ao processar logs.");
        }
    }

    /// <summary>
    /// Registra um evento explícito de acesso/auditoria enviado pelo cliente autenticado.
    /// </summary>
    [HttpPost("access")]
    public async Task<IActionResult> RegisterAccess([FromBody] RegisterAuditAccessRequest request)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized();

        var entry = new LogAuditoria
        {
            UsuarioId = userId,
            Acao = string.IsNullOrWhiteSpace(request.Action) ? "ACCESS" : request.Action.Trim(),
            Recurso = string.IsNullOrWhiteSpace(request.ResourceId) ? "APP" : request.ResourceId.Trim(),
            IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1",
            DataHora = DateTime.UtcNow,
            Detalhes = System.Text.Json.JsonSerializer.Serialize(new { resourceId = request.ResourceId })
        };

        await _repository.CreateAsync(entry);
        await _repository.SaveChangesAsync();
        return StatusCode(201, entry);
    }
}

public record RegisterAuditAccessRequest(string? ResourceId, string? Action);
