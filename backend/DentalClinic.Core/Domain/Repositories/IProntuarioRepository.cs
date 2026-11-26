using DentalClinic.Core.Domain.Entities;

namespace DentalClinic.Core.Domain.Repositories;

public interface IProntuarioRepository
{
    // Odontograma
    Task<Odontogram?> GetOdontogramByPatientIdAsync(Guid patientId);
    Task SaveOdontogramAsync(Odontogram odontogram);

    // Evoluções
    Task<Evolution> AddEvolutionAsync(Guid patientId, string description, Guid professorId, Guid studentId, Guid? clinicId = null);
    Task<IEnumerable<Evolution>> GetEvolutionHistoryAsync(Guid patientId);
    Task<Evolution?> GetEvolutionByIdAsync(Guid id);
    Task UpdateEvolutionAsync(Evolution evolution);

    // Documentos
    Task<Prescription> CreatePrescriptionAsync(Prescription prescription);
    Task<IEnumerable<Prescription>> GetPrescriptionHistoryAsync(Guid patientId);
    Task<MedicalCertificate> CreateCertificateAsync(MedicalCertificate certificate);
    Task<IEnumerable<MedicalCertificate>> GetCertificateHistoryAsync(Guid patientId);

    // Anamnese
    Task<Anamnese?> GetAnamneseByPatientIdAsync(Guid patientId);
    Task SaveAnamneseAsync(Anamnese anamnese);

    // Fichas Clínicas Versionadas (anamnese, extraoral, intraoral, periograma, endodontia, ppr, tcle)
    Task<ClinicalSheetRecord?> GetLatestClinicalSheetAsync(Guid patientId, string sheetType);
    Task<ClinicalSheetRecord> SaveClinicalSheetAsync(Guid patientId, string sheetType, string dataJson, Guid userId);
    Task<IEnumerable<ClinicalSheetRecord>> GetClinicalSheetHistoryAsync(Guid patientId, string sheetType);
    Task<IEnumerable<ClinicalSheetRecord>> GetAllLatestClinicalSheetsAsync(Guid patientId);
    Task<IEnumerable<ClinicalSheetRecord>> GetAllClinicalSheetVersionsAsync(Guid patientId);
}
