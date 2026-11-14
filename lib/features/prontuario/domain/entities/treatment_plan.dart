import 'package:freezed_annotation/freezed_annotation.dart';

// part 'treatment_plan.freezed.dart';
// part 'treatment_plan.g.dart';

@freezed
class TreatmentPlan {
  final String id;
  final String patientId;
  final String description;
  final List<TreatmentItem> items;
  final String status;
  final DateTime createdAt;

  const TreatmentPlan({
    required this.id,
    required this.patientId,
    required this.description,
    required this.items,
    required this.status,
    required this.createdAt,
  });

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) {
    return TreatmentPlan(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      description: json['description'] as String? ?? '',
      items: (json['items'] as List?)?.map((e) => TreatmentItem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

@freezed
class TreatmentItem {
  final String id;
  final String procedureId;
  final String procedureName;
  final int? toothNumber;
  final String status;
  final String? observation;

  const TreatmentItem({
    required this.id,
    required this.procedureId,
    required this.procedureName,
    this.toothNumber,
    required this.status,
    this.observation,
  });

  factory TreatmentItem.fromJson(Map<String, dynamic> json) {
    return TreatmentItem(
      id: json['id'] as String? ?? '',
      procedureId: json['procedureId'] as String? ?? '',
      procedureName: json['procedureName'] as String? ?? '',
      toothNumber: json['toothNumber'] as int?,
      status: json['status'] as String? ?? 'pending',
      observation: json['observation'] as String?,
    );
  }
}
