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
    private readonly IPatientRepository _patientRepository;
    private readonly IClinicRepository _clinicRepository;
    private readonly ILogger<AppointmentsController> _logger;

    public AppointmentsController(
        IAppointmentRepository appointmentRepository,
        IUserRepository userRepository,
        IPatientRepository patientRepository,
        IClinicRepository clinicRepository,
        ILogger<AppointmentsController> logger)
    {
        _appointmentRepository = appointmentRepository;
        _userRepository = userRepository;
        _patientRepository = patientRepository;
        _clinicRepository = clinicRepository;
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
        var startTime = request.StartTime.Kind == DateTimeKind.Utc
            ? request.StartTime
            : DateTime.SpecifyKind(request.StartTime, DateTimeKind.Utc);
        var endTime = request.EndTime.Kind == DateTimeKind.Utc
            ? request.EndTime
            : DateTime.SpecifyKind(request.EndTime, DateTimeKind.Utc);

        if (endTime <= startTime)
            return BadRequest("O horário de término deve ser posterior ao início.");
        if (await _patientRepository.GetByIdAsync(request.PatientId) == null)
            return BadRequest("O paciente selecionado não existe no servidor.");

        var clinicName = string.IsNullOrWhiteSpace(request.ClinicName)
            ? null
            : request.ClinicName.Trim();
        var clinic = await _clinicRepository.GetByIdAsync(request.ClinicId);

        if (clinic == null && clinicName != null)
        {
            clinic = (await _clinicRepository.GetAllAsync()).FirstOrDefault(c =>
                string.Equals(c.Name.Trim(), clinicName, StringComparison.OrdinalIgnoreCase));
        }

        if (clinic == null)
        {
            clinic = Clinic.CreateBasic(clinicName ?? "Clínica selecionada", "Clínica Escola", 1, 8, 18);
            clinic.Id = request.ClinicId;
            await _clinicRepository.AddAsync(clinic);
        }

        var effectiveClinicId = clinic.Id;
        var occupied = await _appointmentRepository.GetByRangeAsync(startTime, endTime, effectiveClinicId);
        if (occupied.Any(a => a.StartTime < endTime && a.EndTime > startTime))
            return Conflict("Já existe um agendamento nesse horário para esta clínica.");

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
            startTime,
            endTime,
            effectiveClinicId,
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

        var startTime = request.StartTime.Kind == DateTimeKind.Utc
            ? request.StartTime
            : DateTime.SpecifyKind(request.StartTime, DateTimeKind.Utc);
        var endTime = request.EndTime.Kind == DateTimeKind.Utc
            ? request.EndTime
            : DateTime.SpecifyKind(request.EndTime, DateTimeKind.Utc);

        if (endTime <= startTime)
            return BadRequest("O horário de término deve ser posterior ao início.");

        var occupied = await _appointmentRepository.GetByRangeAsync(startTime, endTime, appointment.ClinicId);
        if (occupied.Any(a => a.Id != id && a.StartTime < endTime && a.EndTime > startTime))
            return Conflict("Já existe um agendamento nesse horário para esta clínica.");

        appointment.Reschedule(startTime, endTime);
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
    string? ProfessorName,
    string? ClinicName);

public record AppointmentResponse
{
    public AppointmentResponse(Appointment appointment)
    {
        Id = appointment.Id;
        PatientId = appointment.PatientId;
        PatientName = appointment.Patient?.FullName ?? "Paciente não informado";
        DoctorId = appointment.DoctorId;
        DoctorName = appointment.Doctor?.Name ?? "Não informado";
        StudentId = appointment.StudentId;
        StudentName = appointment.StudentName;
        ProfessorId = appointment.ProfessorId;
        ProfessorName = appointment.ProfessorName;
        StartTime = appointment.StartTime;
        EndTime = appointment.EndTime;
        Status = appointment.Status;
        ProcedureName = appointment.ProcedureName;
        Notes = appointment.Notes;
        ClinicId = appointment.ClinicId;
        ArrivalTime = appointment.ArrivalTime;
        ActualStartTime = appointment.ActualStartTime;
        ActualEndTime = appointment.ActualEndTime;
    }

    public Guid Id { get; init; }
    public Guid PatientId { get; init; }
    public string PatientName { get; init; } = "Paciente não informado";
    public Guid DoctorId { get; init; }
    public string DoctorName { get; init; } = "Não informado";
    public Guid? StudentId { get; init; }
    public string? StudentName { get; init; }
    public Guid? ProfessorId { get; init; }
    public string? ProfessorName { get; init; }
    public DateTime StartTime { get; init; }
    public DateTime EndTime { get; init; }
    public AppointmentStatus Status { get; init; }
    public string? ProcedureName { get; init; }
    public string? Notes { get; init; }
    public Guid ClinicId { get; init; }
    public DateTime? ArrivalTime { get; init; }
    public DateTime? ActualStartTime { get; init; }
    public DateTime? ActualEndTime { get; init; }
}
