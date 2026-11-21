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

      final data = response.data is List ? response.data as List : const [];
      final remoteAppointments = <Appointment>[];
      for (final item in data) {
        if (item is Map) {
          try {
            remoteAppointments.add(_appointmentFromJson(Map<String, dynamic>.from(item)));
          } catch (e) {
            _logger.warning('Agendamento remoto inválido ignorado: $e');
          }
        }
      }

      await _updateLocalCache(remoteAppointments);

      return remoteAppointments.where((appointment) {
        final inRange = !appointment.startTime.isBefore(start) &&
            !appointment.startTime.isAfter(end);
        final inClinic = clinicId == null || appointment.clinicId == clinicId;
        return inRange && inClinic;
      }).toList();
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
        if (response.data is Map) {
          final newAppointment = _appointmentFromJson(Map<String, dynamic>.from(response.data));
          await _saveLocal(newAppointment, true);
          return newAppointment;
        }
        await _saveLocal(appointment, true);
        return appointment;
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
            await (db.update(db.appointmentsLocal)
                  ..where((t) => (t as dynamic).id.equals((row as dynamic).id)))
                .write(const AppointmentsLocalCompanion(isSynced: Value(true)));
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
      await (db.update(db.appointmentsLocal)
            ..where((t) => (t as dynamic).id.equals(id)))
          .write(AppointmentsLocalCompanion(
            status: Value(status.name),
            isSynced: Value(isSynced),
          ));
    } catch (_) {}
  }

  Future<void> _saveLocal(Appointment app, bool isSynced) async {
    final dynamic db = _localDb;
    try {
      await db.into(db.appointmentsLocal).insertOnConflictUpdate(
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
    } catch (_) {}
  }

  Future<void> _updateLocalCache(List<Appointment> appointments) async {
    for (var app in appointments) {
      await _saveLocal(app, true);
    }
  }

  Appointment _appointmentFromJson(Map<String, dynamic> json) {
    AppointmentStatus status;
    final rawStatus = json['status'];
    if (rawStatus is int) {
      final index = rawStatus >= 1 ? rawStatus - 1 : rawStatus;
      status = index >= 0 && index < AppointmentStatus.values.length
          ? AppointmentStatus.values[index]
          : AppointmentStatus.scheduled;
    } else {
      status = AppointmentStatus.values.firstWhere(
        (e) => e.name == rawStatus?.toString(),
        orElse: () => AppointmentStatus.scheduled,
      );
    }

    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      return DateTime.parse(value.toString());
    }

    return Appointment(
      id: json['id'].toString(),
      patientId: json['patientId']?.toString() ?? '',
      patientName: json['patientName']?.toString() ?? 'Paciente não informado',
      doctorId: json['doctorId']?.toString() ?? '',
      doctorName: json['doctorName']?.toString() ?? 'Não informado',
      studentId: json['studentId']?.toString(),
      studentName: json['studentName']?.toString(),
      professorId: json['professorId']?.toString(),
      professorName: json['professorName']?.toString(),
      startTime: parseDate(json['startTime']),
      endTime: parseDate(json['endTime']),
      status: status,
      procedureName: json['procedureName']?.toString(),
      notes: json['notes']?.toString(),
      clinicId: json['clinicId']?.toString() ?? '',
      arrivalTime: json['arrivalTime'] == null ? null : parseDate(json['arrivalTime']),
      actualStartTime: json['actualStartTime'] == null ? null : parseDate(json['actualStartTime']),
      actualEndTime: json['actualEndTime'] == null ? null : parseDate(json['actualEndTime']),
    );
  }

  Appointment _mapSchemaToEntity(dynamic row) {
    final dataMap = row.toJson();
    return _appointmentFromJson(dataMap);
  }
}
