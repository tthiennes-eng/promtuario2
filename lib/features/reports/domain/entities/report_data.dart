import 'package:freezed_annotation/freezed_annotation.dart';

// part 'report_data.freezed.dart';
// part 'report_data.g.dart';

class SpecialtyProduction {
  final String specialty;
  final int appointmentCount;
  final double efficiencyRate;

  const SpecialtyProduction({
    required this.specialty,
    required this.appointmentCount,
    required this.efficiencyRate,
  });

  factory SpecialtyProduction.fromJson(Map<String, dynamic> json) {
    return SpecialtyProduction(
      specialty: json['specialty'] as String? ?? '',
      appointmentCount: json['appointmentCount'] as int? ?? 0,
      efficiencyRate: (json['efficiencyRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ClinicPerformanceMetrics {
  final int totalProceduresThisMonth;
  final double occupancyRate;
  final double absenceRate;
  final List<SpecialtyProduction> specialtyProduction;

  const ClinicPerformanceMetrics({
    required this.totalProceduresThisMonth,
    required this.occupancyRate,
    required this.absenceRate,
    required this.specialtyProduction,
  });

  factory ClinicPerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return ClinicPerformanceMetrics(
      totalProceduresThisMonth: json['totalProceduresThisMonth'] as int? ?? 0,
      occupancyRate: (json['occupancyRate'] as num?)?.toDouble() ?? 0.0,
      absenceRate: (json['absenceRate'] as num?)?.toDouble() ?? 0.0,
      specialtyProduction: (json['specialtyProduction'] as List?)
              ?.map((e) => SpecialtyProduction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MonthlyGrowth {
  final String month;
  final int patientCount;

  const MonthlyGrowth({required this.month, required this.patientCount});

  factory MonthlyGrowth.fromJson(Map<String, dynamic> json) {
    return MonthlyGrowth(
      month: json['month'] as String? ?? '',
      patientCount: json['patientCount'] as int? ?? 0,
    );
  }
}
