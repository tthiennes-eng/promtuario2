import 'package:freezed_annotation/freezed_annotation.dart';

// part 'odontogram.freezed.dart';
// part 'odontogram.g.dart';

class ToothCondition {
  final int toothNumber;
  final List<ToothSurface> surfaces;
  final ToothStatus condition;
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
      condition: ToothStatus.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => ToothStatus.higido,
      ),
      observation: json['observation'] as String?,
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
      };

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
}

enum ToothSurface { vestibular, lingual, oclusal, mesial, distal }

enum ToothStatus { higido, carie, restaurado, perdido, endodontia, implante }
