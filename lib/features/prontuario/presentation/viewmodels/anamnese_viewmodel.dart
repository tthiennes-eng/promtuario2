import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/prontuario/domain/entities/anamnese.dart';
import 'package:promt/core/providers/providers.dart';

/// Gerencia as anamneses dos pacientes.
class AnamneseViewModel extends StateNotifier<AsyncValue<List<Anamnese>>> {
  final Ref ref;
  final String patientId;

  AnamneseViewModel(this.ref, this.patientId) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = await AsyncValue.guard(() => 
      ref.read(prontuarioRepositoryProvider).getAnamneses(patientId)
    );
  }

  Future<void> refresh() async => _init();

  Future<void> saveAnamnese(Map<String, dynamic> responses) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(prontuarioRepositoryProvider).saveAnamnese(patientId, responses);
      return await ref.read(prontuarioRepositoryProvider).getAnamneses(patientId);
    });
  }
}

final anamneseViewModelProvider = StateNotifierProvider.family<AnamneseViewModel, AsyncValue<List<Anamnese>>, String>((ref, patientId) {
  return AnamneseViewModel(ref, patientId);
});
