import 'package:promt/core/utils/date_utils.dart';

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

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String? studentId;
  final String? studentName;
  final String? professorId;
  final String? professorName;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;
  final String? procedureName;
  final String? notes;
  final String clinicId;
  final DateTime? arrivalTime;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    this.studentId,
    this.studentName,
    this.professorId,
    this.professorName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.procedureName,
    this.notes,
    required this.clinicId,
    this.arrivalTime,
    this.actualStartTime,
    this.actualEndTime,
  });

  Appointment copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    String? studentId,
    String? studentName,
    String? professorId,
    String? professorName,
    DateTime? startTime,
    DateTime? endTime,
    AppointmentStatus? status,
    String? procedureName,
    String? notes,
    String? clinicId,
    DateTime? arrivalTime,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      professorId: professorId ?? this.professorId,
      professorName: professorName ?? this.professorName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      procedureName: procedureName ?? this.procedureName,
      notes: notes ?? this.notes,
      clinicId: clinicId ?? this.clinicId,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    String getString(List<String> keys) {
      for (final k in keys) {
        final val = json[k];
        if (val != null && val.toString().isNotEmpty) return val.toString();
      }
      return '';
    }

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
      startTime: SafeDateParser.parse(json['startTime'] ?? json['StartTime'] ?? json['start']),
      endTime: SafeDateParser.parse(json['endTime'] ?? json['EndTime'] ?? json['end']),
      status: parseStatus(json['status'] ?? json['Status']),
      procedureName: getString(['procedureName', 'ProcedureName']),
      notes: getString(['notes', 'Notes', 'observation']),
      clinicId: getString(['clinicId', 'ClinicId', 'clinic_id']),
      arrivalTime: SafeDateParser.parseNullable(json['arrivalTime'] ?? json['ArrivalTime']),
      actualStartTime: SafeDateParser.parseNullable(json['actualStartTime'] ?? json['ActualStartTime']),
      actualEndTime: SafeDateParser.parseNullable(json['actualEndTime'] ?? json['ActualEndTime']),
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
