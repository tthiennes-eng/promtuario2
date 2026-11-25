import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/agenda/domain/entities/wait_list_entry.dart';
import 'package:promt/core/providers/providers.dart';

/// Gerencia a lista de espera de atendimentos filtrada por clínica.
class WaitListViewModel extends StateNotifier<AsyncValue<List<WaitListEntry>>> {
  final Ref ref;
  final String clinicId;

  WaitListViewModel(this.ref, this.clinicId) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = await AsyncValue.guard(() => 
      ref.read(waitListRepositoryProvider).getWaitListByClinic(clinicId)
    );
  }

  Future<void> refresh() async => _init();

  Future<void> addEntry(WaitListEntry entry) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(waitListRepositoryProvider).addToWaitList(entry);
      return await ref.read(waitListRepositoryProvider).getWaitListByClinic(clinicId);
    });
  }

  Future<void> resolve(String id) async {
    state = await AsyncValue.guard(() async {
      await ref.read(waitListRepositoryProvider).resolveEntry(id);
      return await ref.read(waitListRepositoryProvider).getWaitListByClinic(clinicId);
    });
  }
}

final waitListViewModelProvider = StateNotifierProvider.family<WaitListViewModel, AsyncValue<List<WaitListEntry>>, String>((ref, clinicId) {
  return WaitListViewModel(ref, clinicId);
});
