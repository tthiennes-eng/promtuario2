// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treatment_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TreatmentPlanImpl _$$TreatmentPlanImplFromJson(Map<String, dynamic> json) =>
    _$TreatmentPlanImpl(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      description: json['description'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => TreatmentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdByUserId: json['createdByUserId'] as String,
      status: $enumDecode(_$TreatmentPlanStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TreatmentPlanImplToJson(_$TreatmentPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'description': instance.description,
      'items': instance.items,
      'createdByUserId': instance.createdByUserId,
      'status': _$TreatmentPlanStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$TreatmentPlanStatusEnumMap = {
  TreatmentPlanStatus.draft: 'Draft',
  TreatmentPlanStatus.approved: 'Approved',
  TreatmentPlanStatus.inProgress: 'InProgress',
  TreatmentPlanStatus.completed: 'Completed',
  TreatmentPlanStatus.cancelled: 'Cancelled',
};

_$TreatmentItemImpl _$$TreatmentItemImplFromJson(Map<String, dynamic> json) =>
    _$TreatmentItemImpl(
      id: json['id'] as String,
      procedureId: json['procedureId'] as String,
      procedureName: json['procedureName'] as String,
      toothNumber: (json['toothNumber'] as num?)?.toInt(),
      observation: json['observation'] as String?,
      status: $enumDecode(_$TreatmentItemStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$$TreatmentItemImplToJson(_$TreatmentItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'procedureId': instance.procedureId,
      'procedureName': instance.procedureName,
      'toothNumber': instance.toothNumber,
      'observation': instance.observation,
      'status': _$TreatmentItemStatusEnumMap[instance.status]!,
    };

const _$TreatmentItemStatusEnumMap = {
  TreatmentItemStatus.pending: 'Pending',
  TreatmentItemStatus.inProgress: 'InProgress',
  TreatmentItemStatus.completed: 'Completed',
  TreatmentItemStatus.cancelled: 'Cancelled',
};
