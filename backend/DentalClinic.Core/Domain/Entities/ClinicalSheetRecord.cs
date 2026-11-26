using System;

namespace DentalClinic.Core.Domain.Entities;

/// <summary>
/// Armazena fichas clínicas estruturadas (anamnese, extraoral, intraoral,
/// periograma, endodontia, ppr, tcle) com versionamento histórico no PostgreSQL.
/// </summary>
public sealed class ClinicalSheetRecord : Entity
{
    public Guid PatientId { get; private set; }
    public string SheetType { get; private set; } = string.Empty;
    public string DataJson { get; private set; } = "{}";
    public int Version { get; private set; }
    public Guid CreatedByUserId { get; private set; }

    private ClinicalSheetRecord() { }

    public static ClinicalSheetRecord Create(
        Guid patientId,
        string sheetType,
        string dataJson,
        int version,
        Guid createdByUserId)
    {
        return new ClinicalSheetRecord
        {
            PatientId = patientId,
            SheetType = sheetType.Trim().ToLowerInvariant(),
            DataJson = string.IsNullOrWhiteSpace(dataJson) ? "{}" : dataJson,
            Version = version < 1 ? 1 : version,
            CreatedByUserId = createdByUserId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
    }
}
