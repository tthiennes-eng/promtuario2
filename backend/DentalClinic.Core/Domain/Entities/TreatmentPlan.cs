using System;
using System.Collections.Generic;

namespace DentalClinic.Core.Domain.Entities;

/// <summary>
/// Representa o Plano de Tratamento proposto para um paciente.
/// Contém uma lista de procedimentos a serem realizados.
/// </summary>
public sealed class TreatmentPlan : Entity
{
    public Guid PatientId { get; private set; }
    public Patient Patient { get; private set; } = null!;

    public string Description { get; private set; } = string.Empty;

    public List<TreatmentItem> Items { get; private set; } = new();

    public Guid CreatedByUserId { get; private set; }
    public User CreatedBy { get; private set; } = null!;

    public TreatmentPlanStatus Status { get; private set; }

    private TreatmentPlan() { }

    public static TreatmentPlan Create(Guid patientId, Guid createdByUserId, string description)
    {
        return new TreatmentPlan
        {
            PatientId = patientId,
            CreatedByUserId = createdByUserId,
            Description = description,
            Status = TreatmentPlanStatus.Draft
        };
    }

    public void AddItem(Guid procedureId, string procedureName, decimal value, int? toothNumber, string? observation = null)
    {
        Items.Add(TreatmentItem.Create(Id, procedureId, procedureName, value, toothNumber, observation));
        UpdatedAt = DateTime.UtcNow;
    }

    public bool UpdateItemStatus(Guid itemId, TreatmentItemStatus status)
    {
        var item = Items.Find(i => i.Id == itemId);
        if (item == null) return false;

        item.UpdateStatus(status);

        var activeItems = Items.FindAll(i => i.Status != TreatmentItemStatus.Cancelled);
        if (activeItems.Count > 0 && activeItems.TrueForAll(i => i.Status == TreatmentItemStatus.Completed))
        {
            Status = TreatmentPlanStatus.Completed;
        }
        else if (activeItems.Exists(i => i.Status == TreatmentItemStatus.InProgress || i.Status == TreatmentItemStatus.Completed))
        {
            if (Status == TreatmentPlanStatus.Draft || Status == TreatmentPlanStatus.Approved)
                Status = TreatmentPlanStatus.InProgress;
        }

        UpdatedAt = DateTime.UtcNow;
        return true;
    }

    public bool RemoveItem(Guid itemId)
    {
        var item = Items.Find(i => i.Id == itemId);
        if (item == null) return false;
        Items.Remove(item);
        UpdatedAt = DateTime.UtcNow;
        return true;
    }

    public void Approve()
    {
        Status = TreatmentPlanStatus.Approved;
        UpdatedAt = DateTime.UtcNow;
    }

    public void Complete()
    {
        Status = TreatmentPlanStatus.Completed;
        UpdatedAt = DateTime.UtcNow;
    }
}

public enum TreatmentPlanStatus
{
    Draft = 1,
    Approved = 2,
    InProgress = 3,
    Completed = 4,
    Cancelled = 5
}
