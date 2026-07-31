// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpecialtyProductionImpl _$$SpecialtyProductionImplFromJson(
        Map<String, dynamic> json) =>
    _$SpecialtyProductionImpl(
      specialty: json['specialty'] as String,
      appointmentCount: (json['appointmentCount'] as num).toInt(),
      efficiencyRate: (json['efficiencyRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$SpecialtyProductionImplToJson(
        _$SpecialtyProductionImpl instance) =>
    <String, dynamic>{
      'specialty': instance.specialty,
      'appointmentCount': instance.appointmentCount,
      'efficiencyRate': instance.efficiencyRate,
    };

_$ClinicPerformanceMetricsImpl _$$ClinicPerformanceMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$ClinicPerformanceMetricsImpl(
      occupancyRate: (json['occupancyRate'] as num).toDouble(),
      absenceRate: (json['absenceRate'] as num).toDouble(),
      totalProceduresThisMonth:
          (json['totalProceduresThisMonth'] as num).toInt(),
      totalScheduled: (json['totalScheduled'] as num?)?.toInt() ?? 0,
      totalCompleted: (json['totalCompleted'] as num?)?.toInt() ?? 0,
      totalCancelled: (json['totalCancelled'] as num?)?.toInt() ?? 0,
      totalMissed: (json['totalMissed'] as num?)?.toInt() ?? 0,
      usageRate: (json['usageRate'] as num?)?.toDouble() ?? 0.0,
      growthHistory: (json['growthHistory'] as List<dynamic>)
          .map((e) => MonthlyGrowth.fromJson(e as Map<String, dynamic>))
          .toList(),
      specialtyProduction: (json['specialtyProduction'] as List<dynamic>)
          .map((e) => SpecialtyProduction.fromJson(e as Map<String, dynamic>))
          .toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$$ClinicPerformanceMetricsImplToJson(
        _$ClinicPerformanceMetricsImpl instance) =>
    <String, dynamic>{
      'occupancyRate': instance.occupancyRate,
      'absenceRate': instance.absenceRate,
      'totalProceduresThisMonth': instance.totalProceduresThisMonth,
      'totalScheduled': instance.totalScheduled,
      'totalCompleted': instance.totalCompleted,
      'totalCancelled': instance.totalCancelled,
      'totalMissed': instance.totalMissed,
      'usageRate': instance.usageRate,
      'growthHistory': instance.growthHistory,
      'specialtyProduction': instance.specialtyProduction,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };

_$MonthlyGrowthImpl _$$MonthlyGrowthImplFromJson(Map<String, dynamic> json) =>
    _$MonthlyGrowthImpl(
      month: json['month'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$$MonthlyGrowthImplToJson(_$MonthlyGrowthImpl instance) =>
    <String, dynamic>{
      'month': instance.month,
      'count': instance.count,
    };
