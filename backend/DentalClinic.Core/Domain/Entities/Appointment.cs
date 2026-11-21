using System;
using DentalClinic.Core.Domain.ValueObjects;

namespace DentalClinic.Core.Domain.Entities;

public sealed class Appointment : Entity
{
    public Guid PatientId { get; private set; }
    public Patient Patient { get; private set; } = null!;

    public Guid DoctorId { get; private set; }
    public User Doctor { get; private set; } = null!;

    public DateTime StartTime { get; private set; }
    public DateTime EndTime { get; private set; }

    public AppointmentStatus Status { get; private set; }
    public string? ProcedureName { get; private set; }
    public string? Notes { get; private set; }
    public Guid ClinicId { get; private set; }
    public Guid? StudentId { get; private set; }
    public string? StudentName { get; private set; }
    public Guid? ProfessorId { get; private set; }
    public string? ProfessorName { get; private set; }
    public DateTime? ArrivalTime { get; private set; }
    public DateTime? ActualStartTime { get; private set; }
    public DateTime? ActualEndTime { get; private set; }

    private Appointment() { }

    public static Appointment Create(
        Guid patientId,
        Guid doctorId,
        DateTime startTime,
        DateTime endTime,
        Guid clinicId,
        string? procedureName = null,
        string? notes = null,
        Guid? studentId = null,
        string? studentName = null,
        Guid? professorId = null,
        string? professorName = null)
    {
        if (endTime <= startTime)
            throw new InvalidOperationException("End time must be after start time.");

        return new Appointment
        {
            PatientId = patientId,
            DoctorId = doctorId,
            StartTime = startTime,
            EndTime = endTime,
            ClinicId = clinicId,
            ProcedureName = procedureName,
            Notes = notes,
            StudentId = studentId,
            StudentName = string.IsNullOrWhiteSpace(studentName) ? null : studentName.Trim(),
            ProfessorId = professorId,
            ProfessorName = string.IsNullOrWhiteSpace(professorName) ? null : professorName.Trim(),
            Status = AppointmentStatus.Scheduled
        };
    }

    public void UpdateStatus(AppointmentStatus status)
    {
        Status = status;
        UpdatedAt = DateTime.UtcNow;
    }

    public void RegisterArrival()
    {
        ArrivalTime ??= DateTime.UtcNow;
        Status = AppointmentStatus.Arrived;
        UpdatedAt = DateTime.UtcNow;
    }

    public void RegisterStart()
    {
        ActualStartTime ??= DateTime.UtcNow;
        Status = AppointmentStatus.InProgress;
        UpdatedAt = DateTime.UtcNow;
    }

    public void RegisterFinish()
    {
        ActualEndTime ??= DateTime.UtcNow;
        Status = AppointmentStatus.Completed;
        UpdatedAt = DateTime.UtcNow;
    }

    public void Reschedule(DateTime newStart, DateTime newEnd)
    {
        if (newEnd <= newStart)
            throw new InvalidOperationException("End time must be after start time.");

        StartTime = newStart;
        EndTime = newEnd;
        UpdatedAt = DateTime.UtcNow;
    }
}

public enum AppointmentStatus
{
    Scheduled = 1,
    Confirmed = 2,
    Arrived = 3,
    InProgress = 4,
    Completed = 5,
    Cancelled = 6,
    NoShow = 7,
    Missed = 8
}
