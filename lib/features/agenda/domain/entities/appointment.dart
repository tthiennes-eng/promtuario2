import 'package:freezed_annotation/freezed_annotation.dart';

// part 'appointment.freezed.dart';
// part 'appointment.g.dart';

@freezed
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

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      studentId: json['studentId'] as String?,
      studentName: json['studentName'] as String?,
      professorId: json['professorId'] as String?,
      professorName: json['professorName'] as String?,
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: AppointmentStatus.values.firstWhere((e) => e.name == json['status']),
      procedureName: json['procedureName'] as String?,
      notes: json['notes'] as String?,
      clinicId: json['clinicId'] as String? ?? '',
      arrivalTime: json['arrivalTime'] != null ? DateTime.parse(json['arrivalTime']) : null,
      actualStartTime: json['actualStartTime'] != null ? DateTime.parse(json['actualStartTime']) : null,
      actualEndTime: json['actualEndTime'] != null ? DateTime.parse(json['actualEndTime']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'status': status.name,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
  };
}

enum AppointmentStatus {
  scheduled,
  arrived,
  inProgress,
  completed,
  cancelled,
  noShow
}
