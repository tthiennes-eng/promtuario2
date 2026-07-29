import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/prontuario/domain/entities/anamnese.dart';
import 'package:promt/core/providers/providers.dart';

class AnamneseViewModel extends StateNotifier<AsyncValue<List<Anamnese>>> {
  final Ref ref;
  final String patientId;

  AnamneseViewModel(this.ref, this.patientId) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(prontuarioRepositoryProvider).getAnamneses(patientId);
    });
  }

  Future<void> refresh() async => _init();

  Future<void> saveAnamnese(Map<String, dynamic> responses) async {
    final previousState = state;
    state = const AsyncValue.loading();
    
    final result = await AsyncValue.guard(() async {
      await ref.read(prontuarioRepositoryProvider).saveAnamnese(patientId, responses);
      return await ref.read(prontuarioRepositoryProvider).getAnamneses(patientId);
    });

    if (result is AsyncError) {
      state = previousState;
      throw result.error!;
    } else {
      state = result;
    }
  }
}

final anamneseViewModelProvider = StateNotifierProvider.family<AnamneseViewModel, AsyncValue<List<Anamnese>>, String>((ref, patientId) {
  return AnamneseViewModel(ref, patientId);
});
