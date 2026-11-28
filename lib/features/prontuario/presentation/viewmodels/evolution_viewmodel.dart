import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/prontuario/domain/entities/evolution.dart';
import 'package:promt/core/providers/providers.dart';

/// Gerencia as evoluções clínicas dos pacientes.
class EvolutionViewModel extends StateNotifier<AsyncValue<List<Evolution>>> {
  final Ref ref;
  final String patientId;

  EvolutionViewModel(this.ref, this.patientId) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = await AsyncValue.guard(() =>
      ref.read(prontuarioRepositoryProvider).getEvolutions(patientId)
    );
  }

  Future<void> refresh() async => _init();

  Future<void> addEvolution(
    String description,
    String professorId, {
    String? clinicId,
  }) async {
    await ref.read(prontuarioRepositoryProvider).addEvolution(
      patientId,
      description,
      professorId,
      clinicId: clinicId,
    );
    state = await AsyncValue.guard(() =>
      ref.read(prontuarioRepositoryProvider).getEvolutions(patientId)
    );
  }

  Future<void> signEvolution(String evolutionId) async {
    await ref.read(prontuarioRepositoryProvider).signEvolution(evolutionId);
    state = await AsyncValue.guard(() =>
      ref.read(prontuarioRepositoryProvider).getEvolutions(patientId)
    );
  }
}

final evolutionViewModelProvider = StateNotifierProvider.family<EvolutionViewModel, AsyncValue<List<Evolution>>, String>((ref, patientId) {
  return EvolutionViewModel(ref, patientId);
});
