import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/features/dashboard/domain/models/dashboard_summary.dart';

part 'dashboard_viewmodel.g.dart';

/// Observa os indicadores do dashboard diretamente nas tabelas locais Drift.
@riverpod
Stream<DashboardSummary> dashboardSummary(Ref ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.watchSummary();
}
