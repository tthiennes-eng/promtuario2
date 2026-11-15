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

  Map<String, dynamic> toJson() => {'month': month, 'count': count};

  MonthlyGrowthModel copyWith({String? month, int? count}) {
    return MonthlyGrowthModel(month: month ?? this.month, count: count ?? this.count);
  }
}

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
      growthData: (json['growthData'] as List<dynamic>? ?? [])
          .map((e) => MonthlyGrowthModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalPatients': totalPatients,
        'appointmentsToday': appointmentsToday,
        'proceduresThisMonth': proceduresThisMonth,
        'pendingAlerts': pendingAlerts,
        'totalCapacity': totalCapacity,
        'bookedSlots': bookedSlots,
        'growthData': growthData.map((e) => e.toJson()).toList(),
      };

  DashboardStatsModel copyWith({
    int? totalPatients,
    int? appointmentsToday,
    int? proceduresThisMonth,
    int? pendingAlerts,
    int? totalCapacity,
    int? bookedSlots,
    List<MonthlyGrowthModel>? growthData,
  }) {
    return DashboardStatsModel(
      totalPatients: totalPatients ?? this.totalPatients,
      appointmentsToday: appointmentsToday ?? this.appointmentsToday,
      proceduresThisMonth: proceduresThisMonth ?? this.proceduresThisMonth,
      pendingAlerts: pendingAlerts ?? this.pendingAlerts,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      bookedSlots: bookedSlots ?? this.bookedSlots,
      growthData: growthData ?? this.growthData,
    );
  }
}
