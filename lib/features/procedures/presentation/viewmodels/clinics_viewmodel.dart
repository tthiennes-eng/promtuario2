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
      return await repository.getClinics(onlyActive: false);
    });
  }

  Future<void> saveClinic(Clinic clinic) async {
    final repository = ref.read(proceduresRepositoryProvider);
    await repository.saveClinic(clinic);
    await refresh();
  }

  Future<void> toggleClinicStatus(Clinic clinic) async {
    final updated = clinic.copyWith(isActive: !clinic.isActive);
    await saveClinic(updated);
  }

  Future<void> addClinic({
    required String name,
    String? description,
    String? location,
    int capacity = 1,
    int startHour = 8,
    int endHour = 18,
    int slotDuration = 60,
  }) async {
    final clinic = Clinic(
      id: '',
      name: name,
      description: description ?? '',
      location: location ?? '',
      capacity: capacity,
      startHour: startHour,
      endHour: endHour,
      slotDurationMinutes: slotDuration,
      isActive: true,
      metadata: {},
    );
    await saveClinic(clinic);
  }
}

final clinicsViewModelProvider = StateNotifierProvider<ClinicsViewModel, AsyncValue<List<Clinic>>>((ref) {
  return ClinicsViewModel(ref);
});
