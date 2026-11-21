import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

enum AppointmentStatus {
  scheduled,
  confirmed,
  arrived,
  inProgress,
  completed,
  cancelled,
  noShow,
  missed;

  String get displayName {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Agendado';
      case AppointmentStatus.confirmed:
        return 'Confirmado';
      case AppointmentStatus.arrived:
        return 'Chegou';
      case AppointmentStatus.inProgress:
        return 'Em andamento';
      case AppointmentStatus.completed:
        return 'Concluído';
      case AppointmentStatus.cancelled:
        return 'Cancelado';
      case AppointmentStatus.noShow:
        return 'Falta';
      case AppointmentStatus.missed:
        return 'Ausente';
    }
  }
}

@freezed
abstract class Appointment with _$Appointment {
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

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
}
