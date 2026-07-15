import '../../../core/network/api_client.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/i_appointment_repository.dart';

/// Implementação do Repositório de Agenda.
/// Gerencia a persistência e recuperação de agendamentos via API.
class AppointmentRepository implements IAppointmentRepository {
  final ApiClient _apiClient;

  AppointmentRepository(this._apiClient);

  @override
  Future<List<Appointment>> getAppointments({
    required DateTime start,
    required DateTime end,
    String? clinicId,
  }) async {
    final response = await _apiClient.instance.get('/appointments', queryParameters: {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      if (clinicId != null) 'clinicId': clinicId,
    });

    final List<dynamic> data = response.data;
    return data.map((json) => _mapJsonToEntity(json)).toList();
  }

  @override
  Future<Appointment> scheduleAppointment(Appointment appointment) async {
    final response = await _apiClient.instance.post(
      '/appointments',
      data: _mapEntityToJson(appointment),
    );
    return _mapJsonToEntity(response.data);
  }

  @override
  Future<void> updateAppointmentStatus(String id, AppointmentStatus status) async {
    await _apiClient.instance.patch(
      '/appointments/$id/status',
      data: {'status': status.name},
    );
  }

  @override
  Future<void> rescheduleAppointment(String id, DateTime newStart, DateTime newEnd) async {
    await _apiClient.instance.put(
      '/appointments/$id/reschedule',
      data: {
        'startTime': newStart.toIso8601String(),
        'endTime': newEnd.toIso8601String(),
      },
    );
  }

  Appointment _mapJsonToEntity(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patientId'],
      patientName: json['patientName'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      procedureName: json['procedureName'],
      notes: json['notes'],
      clinicId: json['clinicId'],
    );
  }

  Map<String, dynamic> _mapEntityToJson(Appointment appointment) {
    return {
      'patientId': appointment.patientId,
      'doctorId': appointment.doctorId,
      'startTime': appointment.startTime.toIso8601String(),
      'endTime': appointment.endTime.toIso8601String(),
      'status': appointment.status.name,
      'procedureName': appointment.procedureName,
      'notes': appointment.notes,
      'clinicId': appointment.clinicId,
    };
  }
}
