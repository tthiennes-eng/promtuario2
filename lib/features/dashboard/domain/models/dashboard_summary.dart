import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_summary.freezed.dart';

@freezed
abstract class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required int totalPacientes,
    required int agendamentosHoje,
    required int atendimentos,
  }) = _DashboardSummary;
}
