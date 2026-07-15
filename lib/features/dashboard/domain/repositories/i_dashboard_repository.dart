import '../models/dashboard_stats_model.dart';

/// Contrato para o Repositório de Dashboard e Estatísticas.
abstract class IDashboardRepository {
  /// Recupera as estatísticas resumidas para a tela inicial.
  Future<DashboardStatsModel> getStats();
}
