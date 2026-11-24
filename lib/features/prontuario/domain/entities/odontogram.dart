import 'package:promt/core/utils/date_utils.dart';

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

  factory ToothCondition.fromJson(Map<String, dynamic> json) {
    return ToothCondition(
      toothNumber: (json['toothNumber'] ?? json['ToothNumber'] ?? 0) as int,
      surfaces: (json['surfaces'] as List? ?? json['Surfaces'] as List? ?? [])
          .map((e) => ToothSurface.values.firstWhere(
                (s) => s.name == e.toString(),
                orElse: () => ToothSurface.occlusal,
              ))
          .toList(),
      condition: ConditionType.values.firstWhere(
        (e) => e.name == (json['condition'] ?? json['Condition']),
        orElse: () => ConditionType.healthy,
      ),
      observation: (json['observation'] ?? json['Observation']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'toothNumber': toothNumber,
    'surfaces': surfaces.map((e) => e.name).toList(),
    'condition': condition.name,
    'observation': observation,
  };
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

  Odontogram copyWith({
    String? id,
    String? patientId,
    List<ToothCondition>? teeth,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return Odontogram(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      teeth: teeth ?? this.teeth,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  factory Odontogram.fromJson(Map<String, dynamic> json) {
    return Odontogram(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      patientId: (json['patientId'] ?? json['PatientId'] ?? '').toString(),
      teeth: (json['teeth'] as List? ?? json['Teeth'] as List? ?? [])
          .map((e) => ToothCondition.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      updatedAt: SafeDateParser.parse(json['updatedAt'] ?? json['UpdatedAt']),
      updatedBy: (json['updatedBy'] ?? json['UpdatedBy'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'teeth': teeth.map((e) => e.toJson()).toList(),
    'updatedAt': updatedAt.toIso8601String(),
    'updatedBy': updatedBy,
  };
}
