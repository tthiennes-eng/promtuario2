using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using System.Security.Claims;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Infrastructure.Persistence;
using System.Text.Json;

namespace DentalClinic.Api.Filters;

/// <summary>
/// Filtro global de auditoria para conformidade com a LGPD.
/// </summary>
public class AuditFilter : IAsyncActionFilter
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<AuditFilter> _logger;

    public AuditFilter(IServiceScopeFactory scopeFactory, ILogger<AuditFilter> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        var resultContext = await next();

        var userIdClaim = context.HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            return;

        var path = context.HttpContext.Request.Path.ToString();
        var method = context.HttpContext.Request.Method;

        // Registra apenas ações de escrita ou acessos a dados sensíveis (case-insensitive)
        if (method != "GET"
            || path.Contains("prontuario", StringComparison.OrdinalIgnoreCase)
            || path.Contains("odontogram", StringComparison.OrdinalIgnoreCase))
        {
            try
            {
                var statusCode = resultContext.Exception != null && !resultContext.ExceptionHandled
                    ? 500
                    : (resultContext.Result as IStatusCodeActionResult)?.StatusCode
                      ?? context.HttpContext.Response.StatusCode;

                var rawAcao = $"{method} {path}";
                var acao = rawAcao.Length > 100 ? rawAcao[..100] : rawAcao;

                var rawRecurso = path.Split('/').Skip(2).FirstOrDefault() ?? "API";
                var recurso = rawRecurso.Length > 100 ? rawRecurso[..100] : rawRecurso;

                var auditLog = new LogAuditoria
                {
                    UsuarioId = userId,
                    Acao = acao,
                    Recurso = recurso,
                    IpAddress = context.HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1",
                    DataHora = DateTime.UtcNow,
                    Detalhes = JsonSerializer.Serialize(new
                    {
                        StatusCode = statusCode,
                        Path = path,
                        Query = context.HttpContext.Request.QueryString.ToString()
                    })
                };

                using var scope = _scopeFactory.CreateScope();
                var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
                db.LogsAuditoria.Add(auditLog);
                await db.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                _logger.LogWarning("Falha silenciosa na auditoria: {Message}", ex.Message);
            }
        }
    }
}
