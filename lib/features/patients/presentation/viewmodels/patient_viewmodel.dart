import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/patients/domain/entities/patient.dart';
import 'package:promt/core/providers/providers.dart';

/// Notifier responsável pela gestão de pacientes.
class PatientViewModel extends StateNotifier<AsyncValue<List<Patient>>> {
  PatientViewModel(this.ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  final Ref ref;

  /// Recarrega a lista de pacientes.
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

  /// Cadastra um novo paciente. 
  /// O erro é propagado para que a UI possa tratá-lo.
  Future<void> addPatient(Patient patient) async {
    final repository = ref.read(patientRepositoryProvider);
    
    // Atualiza estado local para loading
    state = const AsyncValue.loading();
    
    try {
      await repository.createPatient(patient);
      // Recarrega a lista após o sucesso
      final patients = await repository.getPatients();
      state = AsyncValue.data(patients);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow; // Repropaga para a tela de cadastro tratar
    }
  }
}

/// Provider para o PatientViewModel.
final patientViewModelProvider = StateNotifierProvider<PatientViewModel, AsyncValue<List<Patient>>>((ref) {
  return PatientViewModel(ref);
});
