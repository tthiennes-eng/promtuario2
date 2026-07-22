import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/patients/domain/entities/patient.dart';
import 'package:promt/core/providers/providers.dart';

/// Notifier responsável pela gestão de pacientes.
class PatientViewModel extends StateNotifier<AsyncValue<List<Patient>>> {
  PatientViewModel(this.ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  final Ref ref;

  /// Recarrega a lista de pacientes do repositório.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(patientRepositoryProvider);
      return await repository.getPatients();
    });
  }

  /// Realiza uma busca por pacientes.
  Future<void> searchPatients(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(patientRepositoryProvider);
      return await repository.getPatients(query: query);
    });
  }

  /// Cadastra um novo paciente e atualiza a lista.
  Future<void> addPatient(Patient patient) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(patientRepositoryProvider);
      await repository.createPatient(patient);
      return await repository.getPatients();
    });
  }

  /// Atualiza os dados de um paciente existente.
  Future<void> updatePatient(Patient patient) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(patientRepositoryProvider);
      await repository.updatePatient(patient);
      return await repository.getPatients();
    });
  }
}

/// Provider para o PatientViewModel.
final patientViewModelProvider = StateNotifierProvider<PatientViewModel, AsyncValue<List<Patient>>>((ref) {
  return PatientViewModel(ref);
});
