using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DentalClinic.Api.Controllers;

/// <summary>
/// Controller para gestão de agendamentos e horários da clínica.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class AppointmentsController : ControllerBase
{
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<AppointmentsController> _logger;

    public AppointmentsController(
        IAppointmentRepository appointmentRepository,
        IUserRepository userRepository,
        ILogger<AppointmentsController> logger)
    {
        _appointmentRepository = appointmentRepository;
        _userRepository = userRepository;
        _logger = logger;
    }

    /// <summary>
    /// Recupera agendamentos em um intervalo de tempo.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetByRange([FromQuery] DateTime start, [FromQuery] DateTime end, [FromQuery] Guid? clinicId = null)
    {
        var appointments = await _appointmentRepository.GetByRangeAsync(start, end, clinicId);
        return Ok(appointments);
    }

    /// <summary>
    /// Cria um novo agendamento.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateAppointmentRequest request)
    {
        if (request.PatientId == Guid.Empty || request.ClinicId == Guid.Empty)
            return BadRequest("Paciente e clínica devem possuir IDs válidos.");
        if (request.EndTime <= request.StartTime)
            return BadRequest("O horário de término deve ser posterior ao início.");

        var doctorId = request.DoctorId ?? request.ProfessorId ?? request.StudentId ?? Guid.Empty;
        if (doctorId != Guid.Empty)
        {
            var selectedUser = await _userRepository.GetByIdAsync(doctorId);
            if (selectedUser == null) doctorId = Guid.Empty;
        }
        if (doctorId == Guid.Empty)
            doctorId = (await _userRepository.GetAllAsync()).FirstOrDefault()?.Id ?? Guid.Empty;
        if (doctorId == Guid.Empty)
            return StatusCode(503, "Não há usuários cadastrados no servidor para vincular ao agendamento.");

        var appointment = Appointment.Create(
            request.PatientId,
            doctorId,
            request.StartTime,
            request.EndTime,
            request.ClinicId,
            request.ProcedureName,
            request.Notes,
            request.StudentId,
            request.StudentName,
            request.ProfessorId,
            request.ProfessorName);

        await _appointmentRepository.AddAsync(appointment);

        var created = await _appointmentRepository.GetByIdAsync(appointment.Id);
        return created == null
            ? StatusCode(500, "Falha ao recuperar o agendamento criado.")
            : StatusCode(201, new AppointmentResponse(created));
    }

    /// <summary>
    /// Atualiza o status de um agendamento.
    /// </summary>
    [HttpPatch("{id}/status")]
    public async Task<IActionResult> UpdateStatus(Guid id, [FromBody] UpdateStatusRequest request)
    {
        var appointment = await _appointmentRepository.GetByIdAsync(id);
        if (appointment == null) return NotFound();

        appointment.UpdateStatus(request.Status);
        await _appointmentRepository.UpdateAsync(appointment);

        return NoContent();
    }

    [HttpPatch("{id}/arrival")]
    public async Task<IActionResult> RegisterArrival(Guid id)
    {
        var appointment = await _appointmentRepository.GetByIdAsync(id);
        if (appointment == null) return NotFound();
        appointment.RegisterArrival();
        await _appointmentRepository.UpdateAsync(appointment);
        return NoContent();
    }

    [HttpPatch("{id}/start")]
    public async Task<IActionResult> RegisterStart(Guid id)
    {
        var appointment = await _appointmentRepository.GetByIdAsync(id);
        if (appointment == null) return NotFound();
        appointment.RegisterStart();
        await _appointmentRepository.UpdateAsync(appointment);
        return NoContent();
    }

    [HttpPatch("{id}/finish")]
    public async Task<IActionResult> RegisterFinish(Guid id)
    {
        var appointment = await _appointmentRepository.GetByIdAsync(id);
        if (appointment == null) return NotFound();
        appointment.RegisterFinish();
        await _appointmentRepository.UpdateAsync(appointment);
        return NoContent();
    }

    /// <summary>
    /// Reagenda uma consulta.
    /// </summary>
    [HttpPut("{id}/reschedule")]
    public async Task<IActionResult> Reschedule(Guid id, [FromBody] RescheduleRequest request)
    {
        var appointment = await _appointmentRepository.GetByIdAsync(id);
        if (appointment == null) return NotFound();

        appointment.Reschedule(request.StartTime, request.EndTime);
        await _appointmentRepository.UpdateAsync(appointment);

        return NoContent();
    }
}

public record UpdateStatusRequest(AppointmentStatus Status);
public record RescheduleRequest(DateTime StartTime, DateTime EndTime);
public record CreateAppointmentRequest(
    Guid PatientId,
    Guid? DoctorId,
    Guid ClinicId,
    DateTime StartTime,
    DateTime EndTime,
    string? ProcedureName,
    string? Notes,
    Guid? StudentId,
    string? StudentName,
    Guid? ProfessorId,
    string? ProfessorName);

public record AppointmentResponse(Appointment Appointment)
{
    public Guid Id => Appointment.Id;
    public Guid PatientId => Appointment.PatientId;
    public string PatientName => Appointment.Patient?.FullName ?? "Paciente não informado";
    public Guid DoctorId => Appointment.DoctorId;
    public string DoctorName => Appointment.Doctor?.Name ?? "Não informado";
    public Guid? StudentId => Appointment.StudentId;
    public string? StudentName => Appointment.StudentName;
    public Guid? ProfessorId => Appointment.ProfessorId;
    public string? ProfessorName => Appointment.ProfessorName;
    public DateTime StartTime => Appointment.StartTime;
    public DateTime EndTime => Appointment.EndTime;
    public AppointmentStatus Status => Appointment.Status;
    public string? ProcedureName => Appointment.ProcedureName;
    public string? Notes => Appointment.Notes;
    public Guid ClinicId => Appointment.ClinicId;
    public DateTime? ArrivalTime => Appointment.ArrivalTime;
    public DateTime? ActualStartTime => Appointment.ActualStartTime;
    public DateTime? ActualEndTime => Appointment.ActualEndTime;
}
