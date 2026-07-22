import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/dashboard/domain/models/dashboard_stats_model.dart';
import 'package:promt/core/providers/providers.dart';

/// Gerencia o estado do dashboard com estatísticas da clínica.
class DashboardViewModel extends StateNotifier<AsyncValue<DashboardStatsModel>> {
  DashboardViewModel(this.ref) : super(const AsyncValue.loading()) {
    _loadInitialData();
  }

  final Ref ref;

  Future<void> _loadInitialData() async {
    state = await AsyncValue.guard(() async {
      // Simula um pequeno delay de rede para teste de UI
      await Future.delayed(const Duration(milliseconds: 500));
      
      return const DashboardStatsModel(
        totalPatients: 120,
        appointmentsToday: 8,
        proceduresThisMonth: 45,
        pendingAlerts: 2,
        growthData: [
          MonthlyGrowthModel(month: 'Jan', count: 10),
          MonthlyGrowthModel(month: 'Fev', count: 15),
          MonthlyGrowthModel(month: 'Mar', count: 22),
        ],
      );
    });
  }

  /// Recarrega as estatísticas do dashboard chamando o repositório real.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(dashboardRepositoryProvider).getStats());
  }
}

/// Provider para criar a instância do DashboardViewModel.
final dashboardViewModelProvider = StateNotifierProvider<DashboardViewModel, AsyncValue<DashboardStatsModel>>((ref) {
  return DashboardViewModel(ref);
});
