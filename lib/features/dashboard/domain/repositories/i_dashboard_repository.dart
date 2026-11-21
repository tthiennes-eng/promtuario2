import '../models/dashboard_summary.dart';

/// Contrato para o Repositório de Dashboard e Estatísticas.
abstract class IDashboardRepository {
  /// Observa os indicadores calculados a partir do banco local.
  Stream<DashboardSummary> watchSummary();
}
