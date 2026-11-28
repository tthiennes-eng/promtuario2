using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DentalClinic.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class DashboardController : ControllerBase
{
    private readonly IReportRepository _reportRepository;

    public DashboardController(IReportRepository reportRepository)
    {
        _reportRepository = reportRepository;
    }

    [HttpGet("stats")]
    public async Task<IActionResult> GetStats()
    {
        var stats = await _reportRepository.GetDashboardStatsAsync();
        return Ok(stats);
    }
}
