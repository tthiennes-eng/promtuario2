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

  Map<String, dynamic> toJson() => _$$TreatmentPlanImplToJson(this as _$TreatmentPlanImpl);
}

@freezed
class TreatmentItem with _$TreatmentItem {
  const factory TreatmentItem({
    required String id,
    required String procedureId,
    required String procedureName,
    int? toothNumber,
    String? observation,
    required TreatmentItemStatus status,
  }) = _TreatmentItem;

  factory TreatmentItem.fromJson(Map<String, dynamic> json) => _$TreatmentItemFromJson(json);

  Map<String, dynamic> toJson() => _$$TreatmentItemImplToJson(this as _$TreatmentItemImpl);
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
