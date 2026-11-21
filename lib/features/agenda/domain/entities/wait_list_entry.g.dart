// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wait_list_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WaitListEntry _$WaitListEntryFromJson(Map<String, dynamic> json) =>
    _WaitListEntry(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      clinicId: json['clinicId'] as String,
      priority: json['priority'] as String,
      specialty: json['specialty'] as String,
      observation: json['observation'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WaitListEntryToJson(_WaitListEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'patientName': instance.patientName,
      'clinicId': instance.clinicId,
      'priority': instance.priority,
      'specialty': instance.specialty,
      'observation': instance.observation,
      'createdAt': instance.createdAt.toIso8601String(),
    };
