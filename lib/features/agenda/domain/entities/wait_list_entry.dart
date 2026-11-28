import 'package:promt/core/utils/date_utils.dart';

class WaitListEntry {
  final String id;
  final String patientId;
  final String patientName;
  final String clinicId;
  final String priority;
  final String specialty;
  final String? observation;
  final DateTime createdAt;

  const WaitListEntry({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.clinicId,
    required this.priority,
    required this.specialty,
    this.observation,
    required this.createdAt,
  });

  WaitListEntry copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? clinicId,
    String? priority,
    String? specialty,
    String? observation,
    DateTime? createdAt,
  }) {
    return WaitListEntry(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      clinicId: clinicId ?? this.clinicId,
      priority: priority ?? this.priority,
      specialty: specialty ?? this.specialty,
      observation: observation ?? this.observation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory WaitListEntry.fromJson(Map<String, dynamic> json) {
    String getString(List<String> keys) {
      for (final k in keys) {
        final val = json[k];
        if (val != null && val.toString().isNotEmpty) return val.toString();
      }
      return '';
    }

    String patientName = getString(['patientName', 'PatientName', 'fullName', 'FullName']);
    if (patientName.isEmpty && json['patient'] is Map) {
      final p = Map<String, dynamic>.from(json['patient'] as Map);
      patientName = (p['fullName'] ?? p['FullName'] ?? p['name'] ?? '').toString();
    }

    return WaitListEntry(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      patientId: getString(['patientId', 'PatientId', 'patient_id']),
      patientName: patientName.isNotEmpty ? patientName : 'Paciente',
      clinicId: getString(['clinicId', 'ClinicId', 'clinic_id']),
      priority: getString(['priority', 'Priority']),
      specialty: getString(['specialty', 'Specialty']),
      observation: (json['observation'] ?? json['Observation'])?.toString(),
      createdAt: SafeDateParser.parse(json['createdAt'] ?? json['CreatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'patientName': patientName,
    'clinicId': clinicId,
    'priority': priority,
    'specialty': specialty,
    'observation': observation,
    'createdAt': createdAt.toIso8601String(),
  };
}
