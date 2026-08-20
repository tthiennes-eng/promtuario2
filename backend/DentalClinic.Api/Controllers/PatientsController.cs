using DentalClinic.Api.Hubs;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace DentalClinic.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class PatientsController : ControllerBase
{
    private readonly IPatientRepository _patientRepository;
    private readonly ILogger<PatientsController> _logger;
    private readonly IHubContext<ClinicHub> _hubContext;

    public PatientsController(
        IPatientRepository patientRepository,
        ILogger<PatientsController> logger,
        IHubContext<ClinicHub> hubContext)
    {
        _patientRepository = patientRepository;
        _logger = logger;
        _hubContext = hubContext;
    }

    [HttpGet]
    public async Task<IActionResult> Get(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery(Name = "search")] string? searchTerm = null) // Sincronizado com Flutter
    {
        var patients = await _patientRepository.GetAllAsync(page, pageSize, searchTerm);
        var total = await _patientRepository.CountAsync(searchTerm);

        return Ok(new
        {
            Items = patients,
            Total = total,
            Page = page,
            PageSize = pageSize
        });
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var patient = await _patientRepository.GetByIdAsync(id);
        if (patient == null) return NotFound();
        return Ok(patient);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Patient patient)
    {
        try
        {
            await _patientRepository.AddAsync(patient);

            // Notifica em tempo real todos os terminais conectados na rede
            // local para que a lista de pacientes seja atualizada sem
            // depender de o usuário reabrir a tela manualmente.
            await _hubContext.Clients.All.SendAsync("PatientCreated", patient);

            return CreatedAtAction(nameof(GetById), new { id = patient.Id }, patient);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao criar paciente.");
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] Patient patient)
    {
        if (id != patient.Id) return BadRequest();
        var existing = await _patientRepository.GetByIdAsync(id);
        if (existing == null) return NotFound();

        await _patientRepository.UpdateAsync(patient);

        // Notifica os demais terminais para que sincronizem o cache local.
        await _hubContext.Clients.All.SendAsync("PatientUpdated", patient);

        return NoContent();
    }
}
