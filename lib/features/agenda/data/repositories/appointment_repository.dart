import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/agenda/domain/repositories/i_appointment_repository.dart';

class AppointmentRepository implements IAppointmentRepository {
  final ApiClient _apiClient;
  final AppDatabase _localDb;
  final _logger = Logger('AppointmentRepository');

  AppointmentRepository(this._apiClient, this._localDb);

  @override
  Future<List<Appointment>> getAppointments({
    required DateTime start,
    required DateTime end,
    String? clinicId,
  }) async {
    try {
      final response = await _apiClient.instance.get(
        '/appointments',
        queryParameters: {
          'start': start.toUtc().toIso8601String(),
          'end': end.toUtc().toIso8601String(),
          if (clinicId != null) 'clinicId': clinicId,
        },
      );

      final rawData = response.data;
      List<dynamic> data = [];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        data = rawData['items'] ?? rawData['data'] ?? [];
      }

      final remoteAppointments = data.map((item) => _appointmentFromJson(Map<String, dynamic>.from(item))).toList();
      await _updateLocalCache(
        remoteAppointments,
        start: start,
        end: end,
        clinicId: clinicId,
      );
    } catch (e) {
      _logger.warning('Erro na busca remota: $e');
    }

    final results = await (_localDb.select(_localDb.appointmentsLocal)
          ..where((t) {
            var expr = t.startTime.isBetweenValues(start, end);
            if (clinicId != null) expr = expr & t.clinicId.equals(clinicId);
            return expr;
          }))
        .get();

    return results.map((row) => _mapSchemaToEntity(row)).toList();
  }

  @override
  Future<Appointment> scheduleAppointment(Appointment appointment) async {
    await _saveLocal(appointment, false);
    try {
      final response = await _apiClient.instance.post(
        '/appointments',
        data: _mapEntityToApiJson(appointment),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveLocal(appointment, true);
      }
    } catch (_) {}
    return appointment;
  }

  @override
  Future<void> syncAppointments() async {
    final unsynced = await (_localDb.select(_localDb.appointmentsLocal)..where((t) => t.isSynced.equals(false))).get();
    for (final row in unsynced) {
      try {
        await scheduleAppointment(_mapSchemaToEntity(row));
      } catch (_) {}
    }
  }

  @override
  Future<void> updateAppointmentStatus(String id, AppointmentStatus status) async {
    await _updateLocalStatus(id, status, false);
    try {
      await _apiClient.instance.patch('/appointments/$id/status', data: {'status': status.name});
      await _updateLocalStatus(id, status, true);
    } catch (_) {}
  }

  @override Future<void> registerArrival(String id) async => await _apiClient.instance.patch('/appointments/$id/arrival');
  @override Future<void> registerStart(String id) async => await _apiClient.instance.patch('/appointments/$id/start');
  @override Future<void> registerFinish(String id) async => await _apiClient.instance.patch('/appointments/$id/finish');
  @override Future<void> rescheduleAppointment(String id, DateTime ns, DateTime ne) async {}

  Future<void> _updateLocalStatus(String id, AppointmentStatus status, bool isSynced) async {
    await (_localDb.update(_localDb.appointmentsLocal)..where((t) => t.id.equals(id))).write(
      AppointmentsLocalCompanion(
        status: Value(status.name),
        isSynced: Value(isSynced),
      ),
    );
  }

  Future<void> _saveLocal(Appointment app, bool isSynced) async {
    await _localDb.into(_localDb.appointmentsLocal).insertOnConflictUpdate(
      AppointmentsLocalCompanion(
        id: Value(app.id),
        patientId: Value(app.patientId),
        patientName: Value(app.patientName),
        doctorId: Value(app.doctorId),
        doctorName: Value(app.doctorName),
        studentId: Value(app.studentId),
        studentName: Value(app.studentName),
        professorId: Value(app.professorId),
        professorName: Value(app.professorName),
        startTime: Value(app.startTime),
        endTime: Value(app.endTime),
        status: Value(app.status.name),
        procedureName: Value(app.procedureName),
        notes: Value(app.notes),
        clinicId: Value(app.clinicId),
        isSynced: Value(isSynced),
      ),
    );
  }

  Future<void> _updateLocalCache(
    List<Appointment> appointments, {
    required DateTime start,
    required DateTime end,
    String? clinicId,
  }) async {
    final remoteIds = appointments.map((a) => a.id).toSet();
    final existingSynced = await (_localDb.select(_localDb.appointmentsLocal)
          ..where((t) {
            var expr = t.isSynced.equals(true) &
                t.startTime.isBetweenValues(start, end);
            if (clinicId != null) {
              expr = expr & t.clinicId.equals(clinicId);
            }
            return expr;
          }))
        .get();

    for (final row in existingSynced) {
      if (!remoteIds.contains(row.id)) {
        await (_localDb.delete(_localDb.appointmentsLocal)
              ..where((t) => t.id.equals(row.id)))
            .go();
      }
    }

    for (var app in appointments) {
      await _saveLocal(app, true);
    }
  }

  Appointment _appointmentFromJson(Map<String, dynamic> json) {
    return Appointment.fromJson(json);
  }

  Appointment _mapSchemaToEntity(AppointmentsLocalData row) {
    return Appointment(
      id: row.id,
      patientId: row.patientId,
      patientName: row.patientName,
      doctorId: row.doctorId,
      doctorName: row.doctorName,
      studentId: row.studentId,
      studentName: row.studentName,
      professorId: row.professorId,
      professorName: row.professorName,
      startTime: row.startTime,
      endTime: row.endTime,
      status: AppointmentStatus.values.firstWhere((e) => e.name == row.status, orElse: () => AppointmentStatus.scheduled),
      procedureName: row.procedureName,
      notes: row.notes,
      clinicId: row.clinicId,
    );
  }

  Map<String, dynamic> _mapEntityToApiJson(Appointment app) => {
    'id': app.id,
    'patientId': app.patientId,
    'doctorId': app.doctorId,
    'clinicId': app.clinicId,
    'startTime': app.startTime.toUtc().toIso8601String(),
    'endTime': app.endTime.toUtc().toIso8601String(),
    'procedureName': app.procedureName,
    'notes': app.notes,
    'studentId': app.studentId,
    'studentName': app.studentName,
    'professorId': app.professorId,
    'professorName': app.professorName,
  };
}
