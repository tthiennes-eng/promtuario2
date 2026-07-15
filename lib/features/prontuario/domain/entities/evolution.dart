import 'package:freezed_annotation/freezed_annotation.dart';

part 'evolution.freezed.dart';
part 'evolution.g.dart';

@freezed
class Evolution with _$Evolution {
  const factory Evolution({
    required String id,
    required String patientId,
    required String studentId,
    required String studentName,
    required String professorId,
    required String professorName,
    required String description,
    required bool isSignedByProfessor,
    DateTime? signedAt,
    required DateTime createdAt,
    String? clinicName,
  }) = _Evolution;

  factory Evolution.fromJson(Map<String, dynamic> json) => _$EvolutionFromJson(json);
}
