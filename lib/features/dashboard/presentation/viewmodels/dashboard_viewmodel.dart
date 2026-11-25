import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/features/dashboard/domain/models/dashboard_summary.dart';

/// Provider manual para evitar a dependência de geração de código durante a recuperação do ambiente.
final dashboardSummaryProvider = StreamProvider<DashboardSummary>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.watchSummary();
});
