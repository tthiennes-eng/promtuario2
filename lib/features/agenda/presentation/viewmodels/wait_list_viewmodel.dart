import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/wait_list_entry.dart';
import '../../domain/repositories/i_wait_list_repository.dart';
import '../../../../core/providers/providers.dart';

part 'wait_list_viewmodel.g.dart';

@riverpod
class WaitListViewModel extends _$WaitListViewModel {
  @override
  FutureOr<List<WaitListEntry>> build(String clinicId) async {
    return _fetchWaitList(clinicId);
  }

  Future<List<WaitListEntry>> _fetchWaitList(String clinicId) async {
    final repository = ref.read(waitListRepositoryProvider);
    return await repository.getWaitListByClinic(clinicId);
  }

  Future<void> addEntry(WaitListEntry entry) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(waitListRepositoryProvider);
      await repository.addToWaitList(entry);
      return _fetchWaitList(entry.clinicId);
    });
  }

  Future<void> resolve(String entryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(waitListRepositoryProvider);
      await repository.resolveEntry(entryId);
      return _fetchWaitList(arg); // arg is clinicId
    });
  }
}
