import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/core/providers/providers.dart';

class EndodontiaViewModel extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Ref ref;
  final String patientId;

  EndodontiaViewModel(this.ref, this.patientId) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => 
      ref.read(prontuarioRepositoryProvider).getEndodontia(patientId)
    );
  }

  Future<void> save(Map<String, dynamic> data) async {
    await ref.read(prontuarioRepositoryProvider).saveEndodontia(patientId, data);
    state = AsyncValue.data(data);
  }
}

final endodontiaViewModelProvider = StateNotifierProvider.family<EndodontiaViewModel, AsyncValue<Map<String, dynamic>?>, String>((ref, patientId) {
  return EndodontiaViewModel(ref, patientId);
});
