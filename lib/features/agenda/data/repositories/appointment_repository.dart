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
    List<Appointment> remoteAppointments = [];
    bool remoteSuccess = false;

    try {
      final response = await _apiClient.instance.get('/appointments', queryParameters: {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        if (clinicId != null) 'clinicId': clinicId,
      });

      final List<dynamic> data = response.data ?? [];
      remoteAppointments = data.map((json) => Appointment.fromJson(json)).toList();
      _updateLocalCache(remoteAppointments);
      remoteSuccess = true;
    } catch (e) {
      _logger.warning('Falha ao buscar agendamentos remotos: $e');
    }

    // Sempre busca do banco local para garantir que dados offline apareçam
    final query = _localDb.select(_localDb.appointmentsLocal);
    query.where((t) {
      var expression = t.startTime.isBetweenValues(start, end);
      if (clinicId != null) {
        expression = expression & t.clinicId.equals(clinicId);
      }
      return expression;
    });

    final results = await query.get();
    final localAppointments = results.map((row) => _mapSchemaToEntity(row)).toList();

    // Se a busca remota falhou, retorna o que tem no local.
    // Se a busca remota funcionou, o cache local já foi atualizado, então retornamos o local
    // para garantir consistência entre o que foi salvo offline e o que veio do servidor.
    return localAppointments;
  }

  @override
  Future<Appointment> scheduleAppointment(Appointment appointment) async {
    // 1. Salva localmente primeiro
    await _saveLocal(appointment, false);

    try {
      // 2. Tenta enviar para o servidor
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
      _logger.severe('Erro no agendamento remoto, mantido localmente: $e');
    }
    
    return appointment;
  }

  @override
  Future<void> updateAppointmentStatus(String id, AppointmentStatus status) async {
    try {
      await _apiClient.instance.patch(
        '/appointments/$id/status',
        data: {'status': status.index + 1}, // C# enum starts at 1
      );
      await _updateLocalStatus(id, status, true);
    } catch (e) {
      _logger.warning('Falha ao atualizar status remotamente: $e');
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
    final unsynced = await (_localDb.select(_localDb.appointmentsLocal)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    for (final row in unsynced) {
      try {
        final appointment = _mapSchemaToEntity(row);
        final response = await _apiClient.instance.post(
          '/appointments',
          data: appointment.toJson(),
        );
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          await (_localDb.update(_localDb.appointmentsLocal)..where((t) => t.id.equals(row.id))).write(
            const AppointmentsLocalCompanion(isSynced: Value(true)),
          );
        }
      } catch (e) {
        _logger.warning('Falha ao sincronizar agendamento ${row.id}: $e');
      }
    }
  }

  @override
  Future<void> rescheduleAppointment(String id, DateTime newStart, DateTime newEnd) async {
    try {
      await _apiClient.instance.put(
        '/appointments/$id/reschedule',
        data: {
          'startTime': newStart.toIso8601String(),
          'endTime': newEnd.toIso8601String(),
        },
      );
    } catch (e) {
      _logger.severe('Erro ao reagendar: $e');
      rethrow;
    }
  }

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
      AppointmentsLocalCompanion.insert(
        id: app.id,
        patientName: app.patientName,
        startTime: app.startTime,
        endTime: app.endTime,
        status: app.status.name,
        patientId: Value(app.patientId),
        doctorId: Value(app.doctorId),
        doctorName: Value(app.doctorName),
        studentId: Value(app.studentId),
        studentName: Value(app.studentName),
        professorId: Value(app.professorId),
        professorName: Value(app.professorName),
        procedureName: Value(app.procedureName),
        notes: Value(app.notes),
        clinicId: Value(app.clinicId),
        isSynced: Value(isSynced),
      ),
    );
  }

  void _updateLocalCache(List<Appointment> appointments) async {
    for (var app in appointments) {
      await _saveLocal(app, true);
    }
  }

  Appointment _mapSchemaToEntity(AppointmentsLocalData row) {
    final dataMap = row.toJson();
    
    return Appointment(
      id: row.id,
      patientId: row.patientId, 
      patientName: row.patientName,
      doctorId: row.doctorId,
      doctorName: row.doctorName,
      studentId: dataMap['studentId']?.toString(),
      studentName: dataMap['studentName']?.toString(),
      professorId: dataMap['professorId']?.toString(),
      professorName: dataMap['professorName']?.toString(),
      startTime: row.startTime,
      endTime: row.endTime,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == row.status,
        orElse: () => AppointmentStatus.scheduled,
      ),
      procedureName: row.procedureName,
      notes: row.notes,
      clinicId: row.clinicId,
    );
  }
}
