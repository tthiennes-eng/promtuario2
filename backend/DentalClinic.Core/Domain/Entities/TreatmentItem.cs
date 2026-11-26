namespace DentalClinic.Core.Domain.Entities;

/// <summary>
/// Item individual de um Plano de Tratamento.
/// </summary>
public sealed class TreatmentItem : Entity
{
    public Guid TreatmentPlanId { get; private set; }
    public Guid ProcedureId { get; private set; }
    public string ProcedureName { get; private set; } = string.Empty;
    public decimal Value { get; private set; }
    public int? ToothNumber { get; private set; }
    public string? Observation { get; private set; }
    public TreatmentItemStatus Status { get; private set; }

    private TreatmentItem() { }

    public static TreatmentItem Create(
        Guid treatmentPlanId,
        Guid procedureId,
        string procedureName,
        decimal value,
        int? toothNumber,
        string? observation = null)
    {
        return new TreatmentItem
        {
            TreatmentPlanId = treatmentPlanId,
            ProcedureId = procedureId,
            ProcedureName = procedureName,
            Value = value,
            ToothNumber = toothNumber,
            Observation = observation,
            Status = TreatmentItemStatus.Pending
        };
    }

    public void UpdateStatus(TreatmentItemStatus status)
    {
        Status = status;
        UpdatedAt = DateTime.UtcNow;
    }

    public void MarkAsCompleted()
    {
        Status = TreatmentItemStatus.Completed;
        UpdatedAt = DateTime.UtcNow;
    }

    public void Cancel()
    {
        Status = TreatmentItemStatus.Cancelled;
        UpdatedAt = DateTime.UtcNow;
    }
}

public enum TreatmentItemStatus
{
    Pending = 1,
    InProgress = 2,
    Completed = 3,
    Cancelled = 4
}
