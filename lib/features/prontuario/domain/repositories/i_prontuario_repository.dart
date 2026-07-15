import '../entities/odontogram.dart';
import '../entities/prescription.dart';
import '../entities/anamnese.dart';
import '../entities/treatment_plan.dart';

/// Contrato para o Repositório de Prontuário.
/// Define as operações para Odontograma, Evoluções, Receitas, Atestados, Anamnese e Plano de Tratamento.
abstract class IProntuarioRepository {
  /// Recupera o odontograma mais recente de um paciente.
  Future<Odontogram> getOdontogram(String patientId);

  /// Salva ou atualiza o odontograma de um paciente.
  Future<void> saveOdontogram(Odontogram odontogram);

  /// Registra uma nova evolução (nota clínica) no prontuário.
  Future<void> addEvolution(String patientId, String description, String professorId);

  /// Recupera o histórico de evoluções de um paciente.
  Future<List<Map<String, dynamic>>> getEvolutionHistory(String patientId);

  /// Assina digitalmente uma evolução clínica (Ação do Professor).
  Future<void> signEvolution(String evolutionId);

  /// Gera e salva uma nova receita para o paciente.
  Future<Prescription> createPrescription(Prescription prescription);

  /// Recupera o histórico de receitas do paciente.
  Future<List<Prescription>> getPrescriptionHistory(String patientId);

  /// Gera um novo atestado médico/odontológico.
  Future<MedicalCertificate> createCertificate(MedicalCertificate certificate);

  /// Recupera a anamnese de um paciente.
  Future<Anamnese?> getAnamneseByPatientId(String patientId);

  /// Salva ou atualiza a anamnese.
  Future<void> saveAnamnese(Anamnese anamnese);

  /// Recupera o plano de tratamento ativo de um paciente.
  Future<TreatmentPlan?> getTreatmentPlan(String patientId);

  /// Cria ou atualiza um plano de tratamento.
  Future<void> saveTreatmentPlan(TreatmentPlan plan);

  /// Atualiza o status de um item do plano de tratamento.
  Future<void> updateTreatmentItemStatus(String planId, String itemId, String status);
}
