import 'package:freezed_annotation/freezed_annotation.dart';

part 'treatment_plan.freezed.dart';
part 'treatment_plan.g.dart';

@freezed
class TreatmentPlan with _$TreatmentPlan {
  const factory TreatmentPlan({
    required String id,
    required String patientId,
    required String description,
    required List<TreatmentItem> items,
    required String createdByUserId,
    required TreatmentPlanStatus status,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _TreatmentPlan;

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) => _$TreatmentPlanFromJson(json);
}

@freezed
class TreatmentItem with _$TreatmentItem {
  const factory TreatmentItem({
    required String id,
    required String procedureId,
    required String procedureName,
    required double value,
    int? toothNumber,
    required TreatmentItemStatus status,
  }) = _TreatmentItem;

  factory TreatmentItem.fromJson(Map<String, dynamic> json) => _$TreatmentItemFromJson(json);
}

enum TreatmentPlanStatus {
  draft,
  approved,
  inProgress,
  completed,
  cancelled,
}

enum TreatmentItemStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}
