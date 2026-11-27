using System.Globalization;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using DentalClinic.Api.Hubs;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

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
    private readonly IHubContext<ClinicHub> _hubContext;

    public AppointmentsController(
        IAppointmentRepository appointmentRepository,
        IUserRepository userRepository,
        IPatientRepository patientRepository,
        IClinicRepository clinicRepository,
        ILogger<AppointmentsController> logger,
        IHubContext<ClinicHub> hubContext)
    {
        _appointmentRepository = appointmentRepository;
        _userRepository = userRepository;
        _patientRepository = patientRepository;
        _clinicRepository = clinicRepository;
        _logger = logger;
        _hubContext = hubContext;
    }

    private static readonly Dictionary<Guid, string> LegacyDeterministicClinicNames = new()
    {
        [Guid.Parse("d502762e-ea17-58c8-a6f1-c6411b2fc980")] = "Clinica I",
        [Guid.Parse("60a9416e-1abd-57d5-9f47-fa96c248e9b8")] = "Clinica II",
        [Guid.Parse("290d2cd7-1c89-573b-a963-22a7ab246a4d")] = "Clinica III",
        [Guid.Parse("6b26aa0d-aa35-5ce6-af4b-425473ad9cae")] = "Clinica IV",
        [Guid.Parse("d4d1d4be-420e-5e7e-aa97-3e0f3a10dbfd")] = "Clinica V",
        [Guid.Parse("5b634cc2-2e86-5dd6-8087-65083457185a")] = "Clinica Integrada Infantil",
        [Guid.Parse("4c63ead2-3450-5e19-abe9-d4bfd2cbc048")] = "Clinica de Emergência",
        [Guid.Parse("5c2d2861-af19-5b42-960b-e733383c2005")] = "Clinica Integrada Adulto I",
        [Guid.Parse("c51bd540-63b7-55ac-a5b3-3dff10456bc7")] = "Clinica Integrada Adulto II",
        [Guid.Parse("a1c3ab4d-0cc3-57c4-8959-5104e5265ec1")] = "Clinica de DTM",
        [Guid.Parse("c4a77fa1-57e0-5685-b28c-a0ef2193f222")] = "Clinica de Odontopediatria"
    };

    private static string NormalizeName(string? name)
    {
        if (string.IsNullOrWhiteSpace(name)) return string.Empty;
        var decomposed = name.Trim().Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder(decomposed.Length);
        foreach (var ch in decomposed)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(ch) != UnicodeCategory.NonSpacingMark)
            {
                sb.Append(char.ToLowerInvariant(ch));
            }
        }
        return Regex.Replace(sb.ToString(), @"\s+", " ");
    }

    /// <summary>
    /// Recupera agendamentos em um intervalo de tempo.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetByRange([FromQuery] DateTime start, [FromQuery] DateTime end, [FromQuery] Guid? clinicId = null)
    {
        var appointments = await _appointmentRepository.GetByRangeAsync(start, end, clinicId);
        var clinics = await _clinicRepository.GetAllAsync();
        var clinicNamesById = clinics.ToDictionary(c => c.Id, c => c.Name);

        var responses = appointments.Select(a =>
            new AppointmentResponse(a, clinicNamesById.TryGetValue(a.ClinicId, out var name) ? name : null));
        return Ok(responses);
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
        if (clinicName == null && LegacyDeterministicClinicNames.TryGetValue(request.ClinicId, out var mappedName))
        {
            clinicName = mappedName;
        }
        var clinic = await _clinicRepository.GetByIdAsync(request.ClinicId);

        if ((clinic == null || string.Equals(clinic.Name.Trim(), "Clínica selecionada", StringComparison.OrdinalIgnoreCase)) &&
            clinicName != null)
        {
            var normalizedTarget = NormalizeName(clinicName);
            var matched = (await _clinicRepository.GetAllAsync()).FirstOrDefault(c =>
                NormalizeName(c.Name) == normalizedTarget);
            if (matched != null) clinic = matched;
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
        if (created == null)
            return StatusCode(500, "Falha ao recuperar o agendamento criado.");

        var response = new AppointmentResponse(created, clinic.Name);
        try
        {
            await _hubContext.Clients.All.SendAsync("AppointmentCreated", response);
        }
        catch (Exception hubEx)
        {
            _logger.LogWarning(hubEx, "Agendamento {AppointmentId} criado, mas falhou a notificação SignalR.", created.Id);
        }

        return StatusCode(201, response);
    }

    private static bool TryParseAppointmentStatus(JsonElement rawStatus, out AppointmentStatus parsed)
    {
        parsed = AppointmentStatus.Scheduled;
        if (rawStatus.ValueKind == JsonValueKind.Number && rawStatus.TryGetInt32(out var intVal))
        {
            if (Enum.IsDefined(typeof(AppointmentStatus), intVal))
            {
                parsed = (AppointmentStatus)intVal;
                return true;
            }
            return false;
        }

        if (rawStatus.ValueKind == JsonValueKind.String)
        {
            var str = rawStatus.GetString()?.Trim() ?? string.Empty;
            if (int.TryParse(str, out var numStr) && Enum.IsDefined(typeof(AppointmentStatus), numStr))
            {
                parsed = (AppointmentStatus)numStr;
                return true;
            }

            if (Enum.TryParse<AppointmentStatus>(str, ignoreCase: true, out var byName))
            {
                parsed = byName;
                return true;
            }

            switch (str.ToLowerInvariant())
            {
                case "falta":
                case "no_show":
                    parsed = AppointmentStatus.NoShow;
                    return true;
                case "ausente":
                    parsed = AppointmentStatus.Missed;
                    return true;
                case "cancelado":
                case "canceled":
                    parsed = AppointmentStatus.Cancelled;
                    return true;
                case "confirmado":
                    parsed = AppointmentStatus.Confirmed;
                    return true;
                case "agendado":
                    parsed = AppointmentStatus.Scheduled;
                    return true;
                case "chegou":
                    parsed = AppointmentStatus.Arrived;
                    return true;
                case "emandamento":
                case "in_progress":
                    parsed = AppointmentStatus.InProgress;
                    return true;
                case "concluido":
                case "concluído":
                    parsed = AppointmentStatus.Completed;
                    return true;
            }
        }

        return false;
    }

    private async Task NotifyAppointmentUpdatedAsync(Guid appointmentId)
    {
        try
        {
            await _hubContext.Clients.All.SendAsync("AppointmentUpdated", appointmentId);
        }
        catch (Exception hubEx)
        {
            _logger.LogWarning(hubEx, "Agendamento {AppointmentId} atualizado, mas falhou a notificação SignalR.", appointmentId);
        }
    }

    /// <summary>
    /// Atualiza o status de um agendamento.
    /// </summary>
    [HttpPatch("{id}/status")]
    public async Task<IActionResult> UpdateStatus(Guid id, [FromBody] UpdateStatusRequest request)
    {
        if (!TryParseAppointmentStatus(request.Status, out var status))
            return BadRequest(new { message = $"Status de agendamento inválido: {request.Status}" });

        var appointment = await _appointmentRepository.GetByIdAsync(id);
        if (appointment == null) return NotFound();

        appointment.UpdateStatus(status);
        await _appointmentRepository.UpdateAsync(appointment);
        await NotifyAppointmentUpdatedAsync(appointment.Id);

        return NoContent();
    }

    [HttpPatch("{id}/arrival")]
    public async Task<IActionResult> RegisterArrival(Guid id)
    {
        var appointment = await _appointmentRepository.GetByIdAsync(id);
        if (appointment == null) return NotFound();
        appointment.RegisterArrival();
        await _appointmentRepository.UpdateAsync(appointment);
        await NotifyAppointmentUpdatedAsync(appointment.Id);
        return NoContent();
    }

    [HttpPatch("{id}/start")]
    public async Task<IActionResult> RegisterStart(Guid id)
    {
        var appointment = await _appointmentRepository.GetByIdAsync(id);
        if (appointment == null) return NotFound();
        appointment.RegisterStart();
        await _appointmentRepository.UpdateAsync(appointment);
        await NotifyAppointmentUpdatedAsync(appointment.Id);
        return NoContent();
    }

    [HttpPatch("{id}/finish")]
    public async Task<IActionResult> RegisterFinish(Guid id)
    {
        var appointment = await _appointmentRepository.GetByIdAsync(id);
        if (appointment == null) return NotFound();
        appointment.RegisterFinish();
        await _appointmentRepository.UpdateAsync(appointment);
        await NotifyAppointmentUpdatedAsync(appointment.Id);
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
        await NotifyAppointmentUpdatedAsync(appointment.Id);

        return NoContent();
    }
}

public record UpdateStatusRequest(JsonElement Status);
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
    public AppointmentResponse(Appointment appointment, string? clinicName = null)
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
        ClinicName = clinicName;
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
    public string? ClinicName { get; init; }
    public DateTime? ArrivalTime { get; init; }
    public DateTime? ActualStartTime { get; init; }
    public DateTime? ActualEndTime { get; init; }
}
