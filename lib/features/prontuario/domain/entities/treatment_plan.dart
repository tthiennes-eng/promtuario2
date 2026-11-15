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
    required String status,
    required DateTime createdAt,
  }) = _TreatmentPlan;

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) => _$TreatmentPlanFromJson(json);
}

@freezed
class TreatmentItem with _$TreatmentItem {
  const factory TreatmentItem({
    required String id,
    required String procedureId,
    required String procedureName,
    int? toothNumber,
    required String status,
    String? observation,
  }) = _TreatmentItem;

  factory TreatmentItem.fromJson(Map<String, dynamic> json) => _$TreatmentItemFromJson(json);
}
