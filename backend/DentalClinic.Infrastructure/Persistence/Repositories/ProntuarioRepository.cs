using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.EntityFrameworkCore;

namespace DentalClinic.Infrastructure.Persistence.Repositories;

public class ProntuarioRepository : IProntuarioRepository
{
    private readonly ApplicationDbContext _context;

    public ProntuarioRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Odontogram?> GetOdontogramByPatientIdAsync(Guid patientId)
    {
        return await _context.Odontograms
            .FirstOrDefaultAsync(o => o.PatientId == patientId);
    }

    public async Task SaveOdontogramAsync(Odontogram odontogram)
    {
        var existing = await GetOdontogramByPatientIdAsync(odontogram.PatientId);
        if (existing == null)
        {
            _context.Odontograms.Add(odontogram);
        }
        else
        {
            existing.ReplaceTeeth(odontogram.Teeth, odontogram.UpdatedBy);
        }

        await _context.SaveChangesAsync();
    }

    public async Task<Evolution> AddEvolutionAsync(Guid patientId, string description, Guid professorId, Guid studentId, Guid? clinicId = null)
    {
        Guid resolvedClinicId;
        if (clinicId.HasValue && clinicId.Value != Guid.Empty)
        {
            resolvedClinicId = clinicId.Value;
        }
        else
        {
            var clinic = await _context.Clinics.FirstOrDefaultAsync();
            resolvedClinicId = clinic?.Id ?? Guid.Empty;
        }

        var resolvedProfessorId = professorId == Guid.Empty ? studentId : professorId;

        var evolution = Evolution.Create(
            patientId,
            studentId,
            resolvedProfessorId,
            resolvedClinicId,
            description
        );

        _context.Evolutions.Add(evolution);
        await _context.SaveChangesAsync();

        return await _context.Evolutions
            .Include(e => e.Professor)
            .Include(e => e.Student)
            .Include(e => e.Clinic)
            .FirstAsync(e => e.Id == evolution.Id);
    }

    public async Task<IEnumerable<Evolution>> GetEvolutionHistoryAsync(Guid patientId)
    {
        return await _context.Evolutions
            .Include(e => e.Professor)
            .Include(e => e.Student)
            .Include(e => e.Clinic)
            .Where(e => e.PatientId == patientId)
            .OrderByDescending(e => e.CreatedAt)
            .ToListAsync();
    }

    public async Task<Evolution?> GetEvolutionByIdAsync(Guid id)
    {
        return await _context.Evolutions
            .Include(e => e.Professor)
            .Include(e => e.Student)
            .Include(e => e.Clinic)
            .FirstOrDefaultAsync(e => e.Id == id);
    }

    public async Task UpdateEvolutionAsync(Evolution evolution)
    {
        _context.Evolutions.Update(evolution);
        await _context.SaveChangesAsync();
    }

    public async Task<Prescription> CreatePrescriptionAsync(Prescription prescription)
    {
        _context.Prescriptions.Add(prescription);
        await _context.SaveChangesAsync();
        return await _context.Prescriptions
            .Include(p => p.Doctor)
            .FirstAsync(p => p.Id == prescription.Id);
    }

    public async Task<IEnumerable<Prescription>> GetPrescriptionHistoryAsync(Guid patientId)
    {
        return await _context.Prescriptions
            .Include(p => p.Doctor)
            .Where(p => p.PatientId == patientId)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();
    }

    public async Task<MedicalCertificate> CreateCertificateAsync(MedicalCertificate certificate)
    {
        _context.Certificates.Add(certificate);
        await _context.SaveChangesAsync();
        return await _context.Certificates
            .Include(c => c.Doctor)
            .FirstAsync(c => c.Id == certificate.Id);
    }

    public async Task<IEnumerable<MedicalCertificate>> GetCertificateHistoryAsync(Guid patientId)
    {
        return await _context.Certificates
            .Include(c => c.Doctor)
            .Where(c => c.PatientId == patientId)
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();
    }

    public async Task<Anamnese?> GetAnamneseByPatientIdAsync(Guid patientId)
    {
        return await _context.Anamneses
            .FirstOrDefaultAsync(a => a.PatientId == patientId);
    }

    public async Task SaveAnamneseAsync(Anamnese anamnese)
    {
        var existing = await GetAnamneseByPatientIdAsync(anamnese.PatientId);
        if (existing == null)
            _context.Anamneses.Add(anamnese);
        else
            _context.Entry(existing).CurrentValues.SetValues(anamnese);

        await _context.SaveChangesAsync();
    }

    public async Task<ClinicalSheetRecord?> GetLatestClinicalSheetAsync(Guid patientId, string sheetType)
    {
        var normalized = sheetType.Trim().ToLowerInvariant();
        return await _context.ClinicalSheets
            .Where(s => s.PatientId == patientId && s.SheetType == normalized)
            .OrderByDescending(s => s.Version)
            .ThenByDescending(s => s.CreatedAt)
            .FirstOrDefaultAsync();
    }

    public async Task<ClinicalSheetRecord> SaveClinicalSheetAsync(Guid patientId, string sheetType, string dataJson, Guid userId)
    {
        var normalized = sheetType.Trim().ToLowerInvariant();
        var latestVersion = await _context.ClinicalSheets
            .Where(s => s.PatientId == patientId && s.SheetType == normalized)
            .Select(s => (int?)s.Version)
            .MaxAsync() ?? 0;

        var record = ClinicalSheetRecord.Create(patientId, normalized, dataJson, latestVersion + 1, userId);
        _context.ClinicalSheets.Add(record);
        await _context.SaveChangesAsync();
        return record;
    }

    public async Task<IEnumerable<ClinicalSheetRecord>> GetClinicalSheetHistoryAsync(Guid patientId, string sheetType)
    {
        var normalized = sheetType.Trim().ToLowerInvariant();
        return await _context.ClinicalSheets
            .Where(s => s.PatientId == patientId && s.SheetType == normalized)
            .OrderByDescending(s => s.Version)
            .ThenByDescending(s => s.CreatedAt)
            .ToListAsync();
    }

    public async Task<IEnumerable<ClinicalSheetRecord>> GetAllLatestClinicalSheetsAsync(Guid patientId)
    {
        var all = await _context.ClinicalSheets
            .Where(s => s.PatientId == patientId)
            .OrderByDescending(s => s.Version)
            .ThenByDescending(s => s.CreatedAt)
            .ToListAsync();

        return all
            .GroupBy(s => s.SheetType)
            .Select(g => g.First())
            .ToList();
    }

    public async Task<IEnumerable<ClinicalSheetRecord>> GetAllClinicalSheetVersionsAsync(Guid patientId)
    {
        return await _context.ClinicalSheets
            .Where(s => s.PatientId == patientId)
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync();
    }
}
