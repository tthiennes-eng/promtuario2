// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'odontogram.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ToothConditionImpl _$$ToothConditionImplFromJson(Map<String, dynamic> json) =>
    _$ToothConditionImpl(
      toothNumber: (json['toothNumber'] as num).toInt(),
      surfaces: (json['surfaces'] as List<dynamic>)
          .map((e) => $enumDecode(_$ToothSurfaceEnumMap, e))
          .toList(),
      condition: $enumDecode(_$ConditionTypeEnumMap, json['condition']),
      observation: json['observation'] as String?,
      lastUpdate: json['lastUpdate'] == null
          ? null
          : DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$$ToothConditionImplToJson(
        _$ToothConditionImpl instance) =>
    <String, dynamic>{
      'toothNumber': instance.toothNumber,
      'surfaces':
          instance.surfaces.map((e) => _$ToothSurfaceEnumMap[e]!).toList(),
      'condition': _$ConditionTypeEnumMap[instance.condition]!,
      'observation': instance.observation,
      'lastUpdate': instance.lastUpdate?.toIso8601String(),
    };

const _$ToothSurfaceEnumMap = {
  ToothSurface.mesial: 'Mesial',
  ToothSurface.distal: 'Distal',
  ToothSurface.occlusal: 'Occlusal',
  ToothSurface.buccal: 'Buccal',
  ToothSurface.lingual: 'Lingual',
  ToothSurface.palatal: 'Palatal',
  ToothSurface.root: 'Root',
};

const _$ConditionTypeEnumMap = {
  ConditionType.healthy: 'Healthy',
  ConditionType.decayed: 'Decayed',
  ConditionType.restored: 'Restored',
  ConditionType.missing: 'Missing',
  ConditionType.implant: 'Implant',
  ConditionType.endodontic: 'Endodontic',
  ConditionType.prosthesis: 'Prosthesis',
};

_$OdontogramImpl _$$OdontogramImplFromJson(Map<String, dynamic> json) =>
    _$OdontogramImpl(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      teeth: (json['teeth'] as List<dynamic>)
          .map((e) => ToothCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String,
    );

Map<String, dynamic> _$$OdontogramImplToJson(_$OdontogramImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'teeth': instance.teeth,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'updatedBy': instance.updatedBy,
    };
