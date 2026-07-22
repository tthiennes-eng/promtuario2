import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/core/providers/providers.dart';

class ClinicsViewModel extends StateNotifier<AsyncValue<List<Clinic>>> {
  ClinicsViewModel(this.ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  final Ref ref;

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(proceduresRepositoryProvider);
      return await repository.getClinics();
    });
  }
}

final clinicsViewModelProvider = StateNotifierProvider<ClinicsViewModel, AsyncValue<List<Clinic>>>((ref) {
  return ClinicsViewModel(ref);
});
