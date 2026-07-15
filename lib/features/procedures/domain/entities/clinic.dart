import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinic.freezed.dart';
part 'clinic.g.dart';

@freezed
class Clinic with _$Clinic {
  const factory Clinic({
    required String id,
    required String name,
    required String description,
    required String specialty, // Matches Specialty enum
    required int maxCapacity,
    required String coordinatorUserId,
    @Default(true) bool isActive,
    required String openingTime,
    required String closingTime,
  }) = _Clinic;

  factory Clinic.fromJson(Map<String, dynamic> json) => _$ClinicFromJson(json);
}
