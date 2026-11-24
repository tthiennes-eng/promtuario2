import 'package:freezed_annotation/freezed_annotation.dart';

part 'wait_list_entry.freezed.dart';

@freezed
class WaitListEntry with _$WaitListEntry {
  const factory WaitListEntry({
    required String id,
    required String patientId,
    required String patientName,
    required String clinicId,
    required String priority,
    required String specialty,
    String? observation,
    required DateTime createdAt,
  }) = _WaitListEntry;

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

  factory WaitListEntry.fromJson(Map<String, dynamic> json) {
    return WaitListEntry(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      patientId: (json['patientId'] ?? json['PatientId'])?.toString() ?? '',
      patientName: (json['patientName'] ?? json['PatientName'] ?? 'Paciente') as String,
      clinicId: (json['clinicId'] ?? json['ClinicId'])?.toString() ?? '',
      priority: (json['priority'] ?? json['Priority'] ?? 'Normal') as String,
      specialty: (json['specialty'] ?? json['Specialty'] ?? 'Geral') as String,
      observation: (json['observation'] ?? json['Observation'])?.toString(),
      createdAt: _safeParse(json['createdAt'] ?? json['CreatedAt']),
    );
  }
}
