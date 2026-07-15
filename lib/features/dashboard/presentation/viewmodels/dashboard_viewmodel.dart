import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/dashboard_stats_model.dart';
import '../../../../core/providers/providers.dart';

part 'dashboard_viewmodel.g.dart';

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  @override
  FutureOr<DashboardStatsModel> build() async {
    return _fetchStats();
  }

  Future<DashboardStatsModel> _fetchStats() async {
    final repository = ref.read(dashboardRepositoryProvider);
    return await repository.getStats();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}
