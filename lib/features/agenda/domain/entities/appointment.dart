import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment.freezed.dart';

enum AppointmentStatus {
  scheduled, confirmed, arrived, inProgress, completed, cancelled, noShow, missed;

  String get displayName {
    switch (this) {
      case AppointmentStatus.scheduled: return 'Agendado';
      case AppointmentStatus.confirmed: return 'Confirmado';
      case AppointmentStatus.arrived: return 'Chegou';
      case AppointmentStatus.inProgress: return 'Em andamento';
      case AppointmentStatus.completed: return 'Concluído';
      case AppointmentStatus.cancelled: return 'Cancelado';
      case AppointmentStatus.noShow: return 'Falta';
      case AppointmentStatus.missed: return 'Ausente';
    }
  }
}

@freezed
class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    String? studentId,
    String? studentName,
    String? professorId,
    String? professorName,
    required DateTime startTime,
    required DateTime endTime,
    required AppointmentStatus status,
    String? procedureName,
    String? notes,
    required String clinicId,
    DateTime? arrivalTime,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
  }) = _Appointment;

  static DateTime _safeParseDate(dynamic v) {
    if (v == null || v.toString().trim().isEmpty || v.toString() == 'null') {
      return DateTime.now();
    }
    try {
      if (v is DateTime) return v.isUtc ? v.toLocal() : v;
      if (v is int) {
        if (v < 10000000000) return DateTime.fromMillisecondsSinceEpoch(v * 1000).toLocal();
        return DateTime.fromMillisecondsSinceEpoch(v).toLocal();
      }
      final s = v.toString().trim();
      final n = int.tryParse(s);
      if (n != null) {
        if (n < 10000000000) return DateTime.fromMillisecondsSinceEpoch(n * 1000).toLocal();
        return DateTime.fromMillisecondsSinceEpoch(n).toLocal();
      }
      final dateStr = (s.contains('T') || s.contains(' ')) ? s : '${s}T00:00:00';
      final dt = DateTime.parse(dateStr);
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (_) {
      return DateTime.now();
    }
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    AppointmentStatus parseStatus(dynamic v) {
      if (v is int) {
        final idx = v >= 1 ? v - 1 : v;
        if (idx >= 0 && idx < AppointmentStatus.values.length) return AppointmentStatus.values[idx];
      }
      final str = v?.toString().toLowerCase() ?? '';
      return AppointmentStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == str,
        orElse: () => AppointmentStatus.scheduled,
      );
    }

    String getString(List<String> keys) {
      for (final k in keys) {
        if (json[k] != null && json[k].toString().isNotEmpty) return json[k].toString();
      }
      return '';
    }

    return Appointment(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      patientId: getString(['patientId', 'PatientId', 'patient_id']),
      patientName: getString(['patientName', 'PatientName', 'fullName', 'FullName', 'patient_name']),
      doctorId: getString(['doctorId', 'DoctorId', 'doctor_id']),
      doctorName: getString(['doctorName', 'DoctorName', 'doctor_name']),
      studentId: (json['studentId'] ?? json['StudentId'])?.toString(),
      studentName: (json['studentName'] ?? json['StudentName'])?.toString(),
      professorId: (json['professorId'] ?? json['ProfessorId'])?.toString(),
      professorName: (json['professorName'] ?? json['ProfessorName'])?.toString(),
      startTime: _safeParseDate(json['startTime'] ?? json['StartTime'] ?? json['start']),
      endTime: _safeParseDate(json['endTime'] ?? json['EndTime'] ?? json['end']),
      status: parseStatus(json['status'] ?? json['Status']),
      procedureName: getString(['procedureName', 'ProcedureName']),
      notes: getString(['notes', 'Notes', 'observation']),
      clinicId: getString(['clinicId', 'ClinicId', 'clinic_id']),
      arrivalTime: json['arrivalTime'] != null ? _safeParseDate(json['arrivalTime']) : null,
      actualStartTime: json['actualStartTime'] != null ? _safeParseDate(json['actualStartTime']) : null,
      actualEndTime: json['actualEndTime'] != null ? _safeParseDate(json['actualEndTime']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'patientName': patientName,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'studentId': studentId,
    'studentName': studentName,
    'professorId': professorId,
    'professorName': professorName,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'status': status.name,
    'procedureName': procedureName,
    'notes': notes,
    'clinicId': clinicId,
    'arrivalTime': arrivalTime?.toIso8601String(),
    'actualStartTime': actualStartTime?.toIso8601String(),
    'actualEndTime': actualEndTime?.toIso8601String(),
  };
}
