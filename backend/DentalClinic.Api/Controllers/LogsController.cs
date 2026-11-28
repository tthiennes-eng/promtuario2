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
        [FromQuery] string? action = null)
    {
        try
        {
            var logs = await _repository.FindAsync(x =>
                (userId == null || x.UsuarioId == userId) &&
                (string.IsNullOrWhiteSpace(action) || x.Acao.Contains(action)));
            var ordered = logs.OrderByDescending(x => x.DataHora).ToList();
            var total = ordered.Count;
            var paged = ordered.Skip(Math.Max(0, page - 1) * pageSize).Take(pageSize).ToList();

            return Ok(new
            {
                Items = paged,
                Total = total,
                Page = page,
                PageSize = pageSize
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
