import 'package:promt/features/prontuario/domain/entities/odontogram.dart';
import 'package:promt/features/prontuario/domain/entities/prescription.dart';
import 'package:promt/features/prontuario/domain/entities/anamnese.dart';
import 'package:promt/features/prontuario/domain/entities/treatment_plan.dart';
import 'package:promt/features/prontuario/domain/entities/evolution.dart';

abstract class IProntuarioRepository {
  Future<Odontogram> getOdontogram(String patientId);
  Future<void> saveOdontogram(Odontogram odontogram);
  
  Future<void> addEvolution(String patientId, String description, String professorId);
  Future<List<Evolution>> getEvolutions(String patientId);
  Future<void> signEvolution(String evolutionId);

  Future<Prescription> createPrescription(Prescription prescription);
  Future<List<Prescription>> getPrescriptionHistory(String patientId);
  
  Future<MedicalCertificate> createCertificate(MedicalCertificate certificate);
  Future<List<MedicalCertificate>> getCertificateHistory(String patientId);

  Future<List<Anamnese>> getAnamneses(String patientId);
  Future<Anamnese?> getAnamneseByPatientId(String patientId);
  Future<void> saveAnamnese(String patientId, Map<String, dynamic> responses);
  
  Future<List<TreatmentPlan>> getTreatmentPlans(String patientId);
  Future<void> saveTreatmentPlan(TreatmentPlan plan);

  Future<void> syncPendingData();
}
