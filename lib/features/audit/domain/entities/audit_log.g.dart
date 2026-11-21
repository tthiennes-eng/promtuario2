// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditLog _$AuditLogFromJson(Map<String, dynamic> json) => _AuditLog(
  id: json['id'] as String,
  usuarioId: json['usuarioId'] as String,
  acao: json['acao'] as String,
  detalhes: json['detalhes'] as String,
  dataHora: DateTime.parse(json['dataHora'] as String),
  ipAddress: json['ipAddress'] as String?,
);

Map<String, dynamic> _$AuditLogToJson(_AuditLog instance) => <String, dynamic>{
  'id': instance.id,
  'usuarioId': instance.usuarioId,
  'acao': instance.acao,
  'detalhes': instance.detalhes,
  'dataHora': instance.dataHora.toIso8601String(),
  'ipAddress': instance.ipAddress,
};
