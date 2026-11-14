import 'package:freezed_annotation/freezed_annotation.dart';

// part 'evolution.freezed.dart';
// part 'evolution.g.dart';

@freezed
class Evolution {
  final String id;
  final String patientId;
  final String? studentId;
  final String? studentName;
  final String? professorId;
  final String? professorName;
  final String description;
  final bool isSignedByProfessor;
  final DateTime? signedAt;
  final DateTime createdAt;
  final String? clinicName;

  const Evolution({
    required this.id,
    required this.patientId,
    this.studentId,
    this.studentName,
    this.professorId,
    this.professorName,
    required this.description,
    this.isSignedByProfessor = false,
    this.signedAt,
    required this.createdAt,
    this.clinicName,
  });

  factory Evolution.fromJson(Map<String, dynamic> json) {
    return Evolution(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      studentId: json['studentId'] as String?,
      studentName: json['studentName'] as String?,
      professorId: json['professorId'] as String?,
      professorName: json['professorName'] as String?,
      description: json['description'] as String? ?? '',
      isSignedByProfessor: json['isSignedByProfessor'] as bool? ?? false,
      signedAt: json['signedAt'] != null ? DateTime.parse(json['signedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      clinicName: json['clinicName'] as String?,
    );
  }
}
