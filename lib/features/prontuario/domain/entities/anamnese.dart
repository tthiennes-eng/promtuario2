import 'package:freezed_annotation/freezed_annotation.dart';

// part 'anamnese.freezed.dart';
// part 'anamnese.g.dart';

@freezed
class Anamnese {
  final String id;
  final String patientId;
  final Map<String, dynamic> responses;
  final DateTime updatedAt;
  final String updatedBy;

  const Anamnese({
    required this.id,
    required this.patientId,
    required this.responses,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory Anamnese.fromJson(Map<String, dynamic> json) {
    return Anamnese(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      responses: json['responses'] as Map<String, dynamic>? ?? {},
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      updatedBy: json['updatedBy'] as String? ?? '',
    );
  }
}
