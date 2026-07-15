import '../../../core/network/api_client.dart';
import '../../domain/models/dashboard_stats_model.dart';
import '../../domain/repositories/i_dashboard_repository.dart';

/// Implementação do repositório de Dashboard.
/// Busca dados estatísticos consolidados do Backend.
class DashboardRepository implements IDashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  @override
  Future<DashboardStatsModel> getStats() async {
    final response = await _apiClient.instance.get('/reports/dashboard-stats');
    return DashboardStatsModel.fromJson(response.data);
  }
}
