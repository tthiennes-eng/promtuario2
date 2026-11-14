import 'package:freezed_annotation/freezed_annotation.dart';

// part 'prescription.freezed.dart';
// part 'prescription.g.dart';

@freezed
class Prescription {
  final String id;
  final String patientId;
  final String clinicId;
  final List<PrescriptionItem> items;
  final String? observations;
  final DateTime createdAt;

  const Prescription({
    required this.id,
    required this.patientId,
    required this.clinicId,
    required this.items,
    this.observations,
    required this.createdAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      clinicId: json['clinicId'] as String? ?? '',
      items: (json['items'] as List?)?.map((e) => PrescriptionItem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      observations: json['observations'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

@freezed
class PrescriptionItem {
  final String medicineName;
  final String dosage;
  final String instructions;

  const PrescriptionItem({
    required this.medicineName,
    required this.dosage,
    required this.instructions,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      medicineName: json['medicineName'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
    );
  }
}

@freezed
class MedicalCertificate {
  final String id;
  final String patientId;
  final String content;
  final int daysOfRest;
  final String? cid;
  final DateTime createdAt;

  const MedicalCertificate({
    required this.id,
    required this.patientId,
    required this.content,
    required this.daysOfRest,
    this.cid,
    required this.createdAt,
  });

  factory MedicalCertificate.fromJson(Map<String, dynamic> json) {
    return MedicalCertificate(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      daysOfRest: json['daysOfRest'] as int? ?? 0,
      cid: json['cid'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
