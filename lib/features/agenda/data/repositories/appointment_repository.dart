import 'package:drift/drift.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/core/utils/date_utils.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/agenda/domain/repositories/i_appointment_repository.dart';

class AppointmentRepository implements IAppointmentRepository {
  final ApiClient _apiClient;
  final AppDatabase _localDb;
  final _logger = Logger('AppointmentRepository');

  static const _defaultClinicNames = [
    'Clinica I', 'Clinica II', 'Clinica III', 'Clinica IV', 'Clinica V',
    'Clinica Integrada Infantil', 'Clinica de Emergência',
    'Clinica Integrada Adulto I', 'Clinica Integrada Adulto II',
    'Clinica de DTM', 'Clinica de Odontopediatria',
  ];

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
      List<dynamic> data = const [];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        for (final key in const ['data', 'items', 'results', 'value', 'appointment', 'Data', 'Items']) {
          final value = rawData[key];
          if (value is List) {
            data = value;
            break;
          }
        }
      }

      final remoteAppointments = <Appointment>[];
      for (final item in data) {
        if (item is Map) {
          try {
            remoteAppointments.add(_appointmentFromJson(Map<String, dynamic>.from(item)));
          } catch (e) {
            _logger.warning('Agendamento remoto inválido: $e');
          }
        }
      }

      await _updateLocalCache(remoteAppointments);

      final localResults = await (_localDb.select(_localDb.appointmentsLocal)
            ..where((t) {
              var expr = t.startTime.isBetweenValues(start, end);
              if (clinicId != null) expr = expr & t.clinicId.equals(clinicId);
              return expr;
            }))
          .get();

      final localAppointments = localResults.map((row) => _mapSchemaToEntity(row)).toList();

      final merged = <String, Appointment>{
        for (final app in localAppointments) app.id: app,
        for (final app in remoteAppointments) app.id: app,
      }.values.where((app) {
        final st = SafeDateParser.parse(app.startTime);
        final inRange = !st.isBefore(start) && !st.isAfter(end);
        final inClinic = clinicId == null || app.clinicId == clinicId;
        return inRange && inClinic;
      }).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

      return merged;
    } catch (e) {
      _logger.warning('Busca remota falhou, usando local: $e');
      final results = await (_localDb.select(_localDb.appointmentsLocal)
            ..where((t) {
              var expr = t.startTime.isBetweenValues(start, end);
              if (clinicId != null) expr = expr & t.clinicId.equals(clinicId);
              return expr;
            }))
          .get();
      return results.map((row) => _mapSchemaToEntity(row)).toList();
    }
  }

  @override
  Future<Appointment> scheduleAppointment(Appointment appointment) async {
    await _saveLocal(appointment, false);
    try {
      final response = await _apiClient.instance.post(
        '/appointments',
        data: {
          'PatientId': appointment.patientId,
          'DoctorId': appointment.doctorId,
          'ClinicId': appointment.clinicId,
          'ClinicName': _clinicNameForId(appointment.clinicId) ?? appointment.clinicId,
          'StartTime': appointment.startTime.toUtc().toIso8601String(),
          'EndTime': appointment.endTime.toUtc().toIso8601String(),
          'ProcedureName': appointment.procedureName,
          'Notes': appointment.notes,
          'StudentId': appointment.studentId,
          'StudentName': appointment.studentName,
          'ProfessorId': appointment.professorId,
          'ProfessorName': appointment.professorName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map) {
          final nested = responseData['data'] ?? responseData['appointment'] ?? responseData['Data'] ?? responseData['Appointment'];
          final json = Map<String, dynamic>.from(nested is Map ? nested : responseData);
          final parsed = _appointmentFromJson(json);
          final saved = parsed.copyWith(
            id: (json['id'] ?? json['Id'] ?? appointment.id).toString(),
            clinicId: parsed.clinicId.isEmpty ? appointment.clinicId : parsed.clinicId,
            patientName: parsed.patientName == 'Paciente' || parsed.patientName.isEmpty ? appointment.patientName : parsed.patientName,
          );
          await _deleteLocal(appointment.id);
          await _saveLocal(saved, true);
          return saved;
        }
      }
      return appointment;
    } catch (e) {
      throw Exception('Falha ao salvar agendamento: $e');
    }
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
    try {
      await _apiClient.instance.patch('/appointments/$id/status', data: {'status': status.index + 1});
      await _updateLocalStatus(id, status, true);
    } catch (_) {
      await _updateLocalStatus(id, status, false);
    }
  }

  @override
  Future<void> registerArrival(String id) async => await _apiClient.instance.patch('/appointments/$id/arrival');
  @override
  Future<void> registerStart(String id) async => await _apiClient.instance.patch('/appointments/$id/start');
  @override
  Future<void> registerFinish(String id) async => await _apiClient.instance.patch('/appointments/$id/finish');
  @override
  Future<void> rescheduleAppointment(String id, DateTime newStart, DateTime newEnd) async {
    await _apiClient.instance.put('/appointments/$id/reschedule', data: {
      'startTime': newStart.toUtc().toIso8601String(),
      'endTime': newEnd.toUtc().toIso8601String(),
    });
  }

  String? _clinicNameForId(String clinicId) {
    for (final name in _defaultClinicNames) {
      if (const Uuid().v5(Uuid.NAMESPACE_URL, 'promtuario-clinic:$name') == clinicId) return name;
    }
    return null;
  }

  Future<void> _deleteLocal(String id) async => await (_localDb.delete(_localDb.appointmentsLocal)..where((t) => t.id.equals(id))).go();

  Future<void> _updateLocalStatus(String id, AppointmentStatus status, bool isSynced) async {
    await (_localDb.update(_localDb.appointmentsLocal)..where((t) => t.id.equals(id))).write(
      AppointmentsLocalCompanion(status: Value(status.name), isSynced: Value(isSynced)),
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

  Future<void> _updateLocalCache(List<Appointment> appointments) async {
    for (var app in appointments) {
      await _saveLocal(app, true);
    }
  }

  Appointment _appointmentFromJson(Map<String, dynamic> json) {
    AppointmentStatus parseStatus(dynamic v) {
      if (v is int) {
        final idx = v >= 1 ? v - 1 : v;
        if (idx >= 0 && idx < AppointmentStatus.values.length) return AppointmentStatus.values[idx];
      }
      final str = v?.toString().toLowerCase() ?? '';
      return AppointmentStatus.values.firstWhere((e) => e.name.toLowerCase() == str, orElse: () => AppointmentStatus.scheduled);
    }

    String getNestedString(dynamic value, List<String> keys) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) {
        for (final k in keys) {
          if (value[k] != null) return value[k].toString();
        }
      }
      return value.toString();
    }

    String resolveValue(List<String> topKeys, List<String> nestedKeys) {
      for (final k in topKeys) {
        if (json[k] != null) {
          return getNestedString(json[k], nestedKeys);
        }
      }
      return '';
    }

    return Appointment(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      patientId: resolveValue(['patientId', 'PatientId', 'patient', 'Patient'], ['id', 'Id', 'patientId']),
      patientName: resolveValue(['patientName', 'PatientName', 'patient', 'Patient', 'fullName', 'FullName'], ['name', 'Name', 'fullName', 'FullName', 'patientName']),
      doctorId: resolveValue(['doctorId', 'DoctorId', 'doctor', 'Doctor'], ['id', 'Id', 'doctorId']),
      doctorName: resolveValue(['doctorName', 'DoctorName', 'doctor', 'Doctor'], ['name', 'Name', 'fullName', 'FullName']),
      studentId: (json['studentId'] ?? json['StudentId'])?.toString(),
      studentName: (json['studentName'] ?? json['StudentName'])?.toString(),
      professorId: (json['professorId'] ?? json['ProfessorId'])?.toString(),
      professorName: (json['professorName'] ?? json['ProfessorName'])?.toString(),
      startTime: SafeDateParser.parse(json['startTime'] ?? json['StartTime'] ?? json['start']),
      endTime: SafeDateParser.parse(json['endTime'] ?? json['EndTime'] ?? json['end']),
      status: parseStatus(json['status'] ?? json['Status']),
      procedureName: (json['procedureName'] ?? json['ProcedureName'])?.toString(),
      notes: (json['notes'] ?? json['Notes'] ?? json['observation'])?.toString(),
      clinicId: resolveValue(['clinicId', 'ClinicId', 'clinic', 'Clinic'], ['id', 'Id']),
      arrivalTime: json['arrivalTime'] != null ? SafeDateParser.parse(json['arrivalTime']) : null,
      actualStartTime: json['actualStartTime'] != null ? SafeDateParser.parse(json['actualStartTime']) : null,
      actualEndTime: json['actualEndTime'] != null ? SafeDateParser.parse(json['actualEndTime']) : null,
    );
  }

  Appointment _mapSchemaToEntity(dynamic row) {
    final r = row as dynamic;
    return Appointment(
      id: r.id as String,
      patientId: r.patientId as String,
      patientName: r.patientName as String,
      doctorId: r.doctorId as String,
      doctorName: r.doctorName as String,
      studentId: r.studentId as String?,
      studentName: r.studentName as String?,
      professorId: r.professorId as String?,
      professorName: r.professorName as String?,
      startTime: SafeDateParser.parse(r.startTime),
      endTime: SafeDateParser.parse(r.endTime),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == r.status,
        orElse: () => AppointmentStatus.scheduled,
      ),
      procedureName: r.procedureName as String?,
      notes: r.notes as String?,
      clinicId: r.clinicId as String,
    );
  }
}
