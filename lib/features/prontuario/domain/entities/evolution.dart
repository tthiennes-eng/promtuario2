import 'package:freezed_annotation/freezed_annotation.dart';

part 'evolution.freezed.dart';
part 'evolution.g.dart';

@freezed
class Evolution with _$Evolution {
  const factory Evolution({
    required String id,
    required String patientId,
    String? studentId,
    String? studentName,
    String? professorId,
    String? professorName,
    required String description,
    @Default(false) bool isSignedByProfessor,
    DateTime? signedAt,
    required DateTime createdAt,
    String? clinicName,
  }) = _Evolution;

  factory Evolution.fromJson(Map<String, dynamic> json) => _$EvolutionFromJson(json);
}
