import '../entities/patient.dart';

/// Contrato para o Repositório de Pacientes.
/// Segue os princípios de DDD e Repository Pattern para abstração de dados.
abstract class IPatientRepository {
  /// Recupera uma lista paginada de pacientes.
  Future<List<Patient>> getPatients({int page = 1, String? query});

  /// Busca um paciente específico pelo ID.
  Future<Patient> getPatientById(String id);

  /// Cadastra um novo paciente no sistema.
  Future<Patient> createPatient(Patient patient);

  /// Atualiza os dados de um paciente existente.
  Future<void> updatePatient(Patient patient);

  /// Busca pacientes no cache local (offline first).
  Future<List<Patient>> getLocalPatients();

  /// Sincroniza dados locais com o servidor.
  Future<void> syncPatients();
}
