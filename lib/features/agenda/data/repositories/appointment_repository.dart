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
      final response = await _apiClient.instance.get('/appointments', queryParameters: {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        if (clinicId != null) 'clinicId': clinicId,
      });

      final List<dynamic> data = response.data ?? [];
      final remoteAppointments = data.map((json) => Appointment.fromJson(json)).toList();
      _updateLocalCache(remoteAppointments);
    } catch (e) {
      _logger.warning('Falha ao buscar agendamentos remotos: $e');
    }

    final dynamic db = _localDb;
    try {
      final query = db.select(db.appointmentsLocal);
      query.where((t) {
        var expression = (t as dynamic).startTime.isBetweenValues(start, end);
        if (clinicId != null) {
          expression = expression & (t as dynamic).clinicId.equals(clinicId);
        }
        return expression;
      });

      final results = await query.get();
      return (results as List).map((row) => _mapSchemaToEntity(row)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Appointment> scheduleAppointment(Appointment appointment) async {
    await _saveLocal(appointment, false);
    try {
      final response = await _apiClient.instance.post(
        '/appointments',
        data: appointment.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final newAppointment = Appointment.fromJson(response.data);
        await _saveLocal(newAppointment, true);
        return newAppointment;
      }
    } catch (e) {
      _logger.severe('Erro no agendamento remoto: $e');
    }
    return appointment;
  }

  @override
  Future<void> updateAppointmentStatus(String id, AppointmentStatus status) async {
    try {
      await _apiClient.instance.patch(
        '/appointments/$id/status',
        data: {'status': status.index + 1},
      );
      await _updateLocalStatus(id, status, true);
    } catch (e) {
      _logger.warning('Falha ao atualizar status: $e');
      await _updateLocalStatus(id, status, false);
    }
  }

  @override
  Future<void> registerArrival(String id) async {
    await _apiClient.instance.patch('/appointments/$id/arrival');
  }

  @override
  Future<void> registerStart(String id) async {
    await _apiClient.instance.patch('/appointments/$id/start');
  }

  @override
  Future<void> registerFinish(String id) async {
    await _apiClient.instance.patch('/appointments/$id/finish');
  }

  @override
  Future<void> syncAppointments() async {
    final dynamic db = _localDb;
    try {
      final unsynced = await (db.select(db.appointmentsLocal)
            ..where((t) => (t as dynamic).isSynced.equals(false)))
          .get();

      for (final row in (unsynced as List)) {
        try {
          final appointment = _mapSchemaToEntity(row);
          final response = await _apiClient.instance.post(
            '/appointments',
            data: appointment.toJson(),
          );
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            await (db.update(db.appointmentsLocal)..where((t) => (t as dynamic).id.equals((row as dynamic).id))).write(
              Insertable.fromMap({'is_synced': true}),
            );
          }
        } catch (_) {}
      }
    } catch (_) {}
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

  Future<void> _updateLocalStatus(String id, AppointmentStatus status, bool isSynced) async {
    final dynamic db = _localDb;
    try {
      await (db.update(db.appointmentsLocal)..where((t) => (t as dynamic).id.equals(id))).write(
        Insertable.fromMap({
          'status': status.name,
          'is_synced': isSynced,
        }),
      );
    } catch (_) {}
  }

  Future<void> _saveLocal(Appointment app, bool isSynced) async {
    final dynamic db = _localDb;
    try {
      await db.into(db.appointmentsLocal).insertOnConflictUpdate(
        Insertable.fromMap({
          'id': app.id,
          'patient_name': app.patientName,
          'start_time': app.startTime.toIso8601String(),
          'end_time': app.endTime.toIso8601String(),
          'status': app.status.name,
          'patient_id': app.patientId,
          'clinic_id': app.clinicId,
          'is_synced': isSynced,
        }),
      );
    } catch (_) {}
  }

  void _updateLocalCache(List<Appointment> appointments) async {
    for (var app in appointments) {
      await _saveLocal(app, true);
    }
  }

  Appointment _mapSchemaToEntity(dynamic row) {
    final dataMap = row.toJson();
    return Appointment(
      id: dataMap['id'],
      patientId: dataMap['patientId'] ?? '', 
      patientName: dataMap['patientName'],
      doctorId: dataMap['doctorId'] ?? '',
      doctorName: dataMap['doctorName'] ?? '',
      startTime: DateTime.parse(dataMap['startTime']),
      endTime: DateTime.parse(dataMap['endTime']),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == dataMap['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      clinicId: dataMap['clinicId'] ?? '',
    );
  }
}
