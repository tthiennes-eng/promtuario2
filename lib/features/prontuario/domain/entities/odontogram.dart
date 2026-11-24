import 'package:freezed_annotation/freezed_annotation.dart';

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
      toothNumber: json['toothNumber'] as int? ?? json['ToothNumber'] as int? ?? 0,
      surfaces: (json['surfaces'] as List? ?? json['Surfaces'] as List?)
              ?.map((e) => ToothSurface.values.firstWhere((s) => s.name == e.toString()))
              .toList() ??
          [],
      condition: ConditionType.values.firstWhere(
        (e) => e.name == (json['condition'] ?? json['Condition']),
        orElse: () => ConditionType.healthy,
      ),
      observation: (json['observation'] ?? json['Observation']) as String?,
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

  static DateTime _safeParse(dynamic v) {
    if (v == null || v.toString().trim().isEmpty || v.toString() == 'null') {
      return DateTime.now();
    }
    try {
      if (v is DateTime) return v.isUtc ? v.toLocal() : v;
      final s = v.toString();
      final dateStr = s.contains('T') || s.contains(' ') ? s : '${s}T00:00:00';
      final dt = DateTime.parse(dateStr);
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (_) {
      return DateTime.now();
    }
  }

  factory Odontogram.fromJson(Map<String, dynamic> json) {
    return Odontogram(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      patientId: (json['patientId'] ?? json['PatientId'])?.toString() ?? '',
      teeth: (json['teeth'] as List? ?? json['Teeth'] as List?)
              ?.map((e) => ToothCondition.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      updatedAt: _safeParse(json['updatedAt'] ?? json['UpdatedAt']),
      updatedBy: (json['updatedBy'] ?? json['UpdatedBy'] ?? '') as String,
    );
  }
}
