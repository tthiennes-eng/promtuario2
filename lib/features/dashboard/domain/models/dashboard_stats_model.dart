import 'package:freezed_annotation/freezed_annotation.dart';

// part 'dashboard_stats_model.freezed.dart';
// part 'dashboard_stats_model.g.dart';

@freezed
class DashboardStatsModel {
  final int totalPatients;
  final int appointmentsToday;
  final int proceduresThisMonth;
  final int pendingAlerts;
  final int totalCapacity;
  final int bookedSlots;
  final List<MonthlyGrowthModel> growthData;

  const DashboardStatsModel({
    required this.totalPatients,
    required this.appointmentsToday,
    required this.proceduresThisMonth,
    required this.pendingAlerts,
    required this.totalCapacity,
    required this.bookedSlots,
    required this.growthData,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalPatients: json['totalPatients'] as int? ?? 0,
      appointmentsToday: json['appointmentsToday'] as int? ?? 0,
      proceduresThisMonth: json['proceduresThisMonth'] as int? ?? 0,
      pendingAlerts: json['pendingAlerts'] as int? ?? 0,
      totalCapacity: json['totalCapacity'] as int? ?? 0,
      bookedSlots: json['bookedSlots'] as int? ?? 0,
      growthData: (json['growthData'] as List?)
              ?.map((e) => MonthlyGrowthModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

@freezed
class MonthlyGrowthModel {
  final String month;
  final int count;

  const MonthlyGrowthModel({
    required this.month,
    required this.count,
  });

  factory MonthlyGrowthModel.fromJson(Map<String, dynamic> json) {
    return MonthlyGrowthModel(
      month: json['month'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}
