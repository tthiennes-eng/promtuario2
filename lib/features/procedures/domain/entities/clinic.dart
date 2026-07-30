import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinic.freezed.dart';
part 'clinic.g.dart';

@freezed
class Clinic with _$Clinic {
  const factory Clinic({
    required String id,
    required String name,
    @Default('') String description,
    String? location,
    @Default(1) int capacity,
    @Default(true) bool isActive,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Clinic;

  factory Clinic.fromJson(Map<String, dynamic> json) => _$ClinicFromJson(json);
}
