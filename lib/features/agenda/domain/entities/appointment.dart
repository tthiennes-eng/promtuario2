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
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : DateTime.now(),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'scheduled'),
        orElse: () => AppointmentStatus.scheduled,
      ),
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
}
