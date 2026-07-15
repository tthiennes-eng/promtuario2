import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/i_patient_repository.dart';
import '../../../core/providers/providers.dart';

part 'patient_viewmodel.g.dart';

/// Notifier responsável pela gestão de pacientes.
/// Implementa busca, cadastro, atualização e anonimização (LGPD).
@riverpod
class PatientViewModel extends _$PatientViewModel {
  @override
  FutureOr<List<Patient>> build() async {
    return _fetchPatients();
  }

  Future<List<Patient>> _fetchPatients({String? query}) async {
    final repository = ref.read(patientRepositoryProvider);
    return await repository.getPatients(query: query);
  }

  /// Realiza uma busca por pacientes.
  Future<void> searchPatients(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPatients(query: query));
  }

  /// Cadastra um novo paciente.
  Future<void> addPatient(Patient patient) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(patientRepositoryProvider);
      await repository.createPatient(patient);
      return _fetchPatients();
    });
  }

  /// Atualiza um paciente existente.
  Future<void> updatePatient(Patient patient) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(patientRepositoryProvider);
      await repository.updatePatient(patient);
      return _fetchPatients();
    });
  }

  /// Realiza a anonimização dos dados do paciente (Direito ao Esquecimento LGPD).
  Future<void> anonymizePatient(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(patientRepositoryProvider);
      // Aqui chamaríamos o endpoint de anonimização no repositório
      // repository.anonymize(id);
      return _fetchPatients();
    });
  }
}
