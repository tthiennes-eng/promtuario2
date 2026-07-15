import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats_model.freezed.dart';
part 'dashboard_stats_model.g.dart';

@freezed
class DashboardStatsModel with _$DashboardStatsModel {
  const factory DashboardStatsModel({
    required int totalPatients,
    required int appointmentsToday,
    required int proceduresThisMonth,
    required int pendingAlerts,
    required List<MonthlyGrowthModel> growthData,
  }) = _DashboardStatsModel;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) => _$DashboardStatsModelFromJson(json);
}

@freezed
class MonthlyGrowthModel with _$MonthlyGrowthModel {
  const factory MonthlyGrowthModel({
    required String month,
    required int count,
  }) = _MonthlyGrowthModel;

  factory MonthlyGrowthModel.fromJson(Map<String, dynamic> json) => _$MonthlyGrowthModelFromJson(json);
}
