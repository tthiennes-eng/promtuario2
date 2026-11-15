import 'package:freezed_annotation/freezed_annotation.dart';

// Enums unificados para evitar erro de exaustividade no switch
enum ToothSurface { mesial, distal, occlusal, buccal, lingual, palatal, root }
enum ConditionType { healthy, decayed, restored, missing, implant, endodontic, prosthesis }

class ToothCondition {
  final int toothNumber;
  final List<ToothSurface> surfaces;
  final ConditionType condition;
  final String? observation;

  const ToothCondition({
    required this.toothNumber,
    required this.surfaces,
    required this.condition,
    this.observation,
  });

  factory ToothCondition.fromJson(Map<String, dynamic> json) {
    return ToothCondition(
      toothNumber: json['toothNumber'] as int? ?? 0,
      surfaces: (json['surfaces'] as List?)
              ?.map((e) => ToothSurface.values.firstWhere((s) => s.name == e))
              .toList() ??
          [],
      condition: ConditionType.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => ConditionType.healthy,
      ),
      observation: json['observation'] as String?,
    );
  }

  ToothCondition copyWith({
    int? toothNumber,
    List<ToothSurface>? surfaces,
    ConditionType? condition,
    String? observation,
  }) {
    return ToothCondition(
      toothNumber: toothNumber ?? this.toothNumber,
      surfaces: surfaces ?? this.surfaces,
      condition: condition ?? this.condition,
      observation: observation ?? this.observation,
    );
  }
}

class Odontogram {
  final String id;
  final String patientId;
  final List<ToothCondition> teeth;
  final DateTime updatedAt;
  final String updatedBy;

  const Odontogram({
    required this.id,
    required this.patientId,
    required this.teeth,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory Odontogram.fromJson(Map<String, dynamic> json) {
    return Odontogram(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      teeth: (json['teeth'] as List?)
              ?.map((e) => ToothCondition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      updatedBy: json['updatedBy'] as String? ?? '',
    );
  }
}
