// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_change_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PatientChangeLogImpl _$$PatientChangeLogImplFromJson(
        Map<String, dynamic> json) =>
    _$PatientChangeLogImpl(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      changesJson: json['changesJson'] as String,
    );

Map<String, dynamic> _$$PatientChangeLogImplToJson(
        _$PatientChangeLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'userId': instance.userId,
      'userName': instance.userName,
      'timestamp': instance.timestamp.toIso8601String(),
      'changesJson': instance.changesJson,
    };
