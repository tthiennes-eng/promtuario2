import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/core/providers/providers.dart';

class PeriogramaViewModel extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Ref ref;
  final String patientId;

  PeriogramaViewModel(this.ref, this.patientId) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => 
      ref.read(prontuarioRepositoryProvider).getPeriograma(patientId)
    );
  }

  Future<void> save(Map<String, dynamic> data) async {
    await ref.read(prontuarioRepositoryProvider).savePeriograma(patientId, data);
    state = AsyncValue.data(data);
  }
}

final periogramaViewModelProvider = StateNotifierProvider.family<PeriogramaViewModel, AsyncValue<Map<String, dynamic>?>, String>((ref, patientId) {
  return PeriogramaViewModel(ref, patientId);
});
