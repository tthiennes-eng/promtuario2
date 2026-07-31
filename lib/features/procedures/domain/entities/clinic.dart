import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinic.freezed.dart';
part 'clinic.g.dart';

@freezed
class Clinic with _$Clinic {
  const factory Clinic({
    required String id,
    required String name,
    String? description,
    String? location,
    @Default(1) int capacity,
    @Default(true) bool isActive,
    @Default(8) int startHour,
    @Default(18) int endHour,
    @Default(60) int slotDurationMinutes,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Clinic;

  factory Clinic.fromJson(Map<String, dynamic> json) => _$ClinicFromJson(json);
}

/// Extensão para permitir acesso aos campos novos mesmo antes da regeneração do código.
extension ClinicX on Clinic {
  int get startHourSafe => (toJson()['startHour'] as num?)?.toInt() ?? 8;
  int get endHourSafe => (toJson()['endHour'] as num?)?.toInt() ?? 18;
  int get slotDurationMinutesSafe => (toJson()['slotDurationMinutes'] as num?)?.toInt() ?? 60;
}
