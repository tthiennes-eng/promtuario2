using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DentalClinic.Api.Controllers;

/// <summary>
/// Controller para fornecer dados estatísticos e relatórios gerenciais.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ReportsController : ControllerBase
{
    private readonly IReportRepository _reportRepository;
    private readonly ILogger<ReportsController> _logger;

    public ReportsController(IReportRepository reportRepository, ILogger<ReportsController> logger)
    {
        _reportRepository = reportRepository;
        _logger = logger;
    }

    /// <summary>
    /// Obtém as estatísticas principais para o Dashboard.
    /// </summary>
    [HttpGet("dashboard-stats")]
    public async Task<IActionResult> GetDashboardStats()
    {
        try
        {
            var stats = await _reportRepository.GetDashboardStatsAsync();
            return Ok(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter estatísticas do dashboard.");
            return StatusCode(500, "Erro interno ao processar estatísticas.");
        }
    }

    /// <summary>
    /// Obtém o relatório de produção por profissional em um período.
    /// </summary>
    [HttpGet("production")]
    [Authorize(Roles = "Admin,Coordinator")]
    public async Task<IActionResult> GetProductionReport(
        [FromQuery] DateTime? start,
        [FromQuery] DateTime? end,
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate)
    {
        var effectiveStart = start ?? startDate ?? DateTime.UtcNow.AddMonths(-1);
        var effectiveEnd = end ?? endDate ?? DateTime.UtcNow;
        var report = await _reportRepository.GetProductionByProfessionalAsync(effectiveStart, effectiveEnd);
        return Ok(report);
    }

    /// <summary>
    /// Obtém métricas gerenciais de ocupação, absenteísmo e produção por clínica/especialidade.
    /// </summary>
    [HttpGet("metrics")]
    public async Task<IActionResult> GetClinicMetrics(
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate,
        [FromQuery] DateTime? start,
        [FromQuery] DateTime? end,
        [FromQuery] Guid? clinicId)
    {
        var effectiveStart = startDate ?? start ?? new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var effectiveEnd = endDate ?? end ?? DateTime.UtcNow;
        var metrics = await _reportRepository.GetClinicMetricsAsync(effectiveStart, effectiveEnd, clinicId);
        return Ok(metrics);
    }

    /// <summary>
    /// Consolida todos os indicadores dos 5 grupos de estudos estatísticos (Epidemiológico,
    /// Associações/Risco, Longitudinal, Gestão/Fluxo e Qualidade/LGPD) + base anonimizada.
    /// </summary>
    [HttpGet("statistical-studies")]
    public async Task<IActionResult> GetStatisticalStudies(
        [FromQuery] DateTime? start,
        [FromQuery] DateTime? end,
        [FromQuery] Guid? clinicId)
    {
        try
        {
            var payload = await _reportRepository.GetStatisticalStudiesAsync(start, end, clinicId);
            return Ok(payload);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao processar estudos estatísticos.");
            return StatusCode(500, new { message = "Erro ao processar estudos estatísticos." });
        }
    }
}
