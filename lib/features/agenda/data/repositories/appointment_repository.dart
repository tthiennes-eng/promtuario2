import 'package:drift/drift.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/agenda/domain/repositories/i_appointment_repository.dart';

class AppointmentRepository implements IAppointmentRepository {
  final ApiClient _apiClient;
  final AppDatabase _localDb;
  final _logger = Logger('AppointmentRepository');

  static const _defaultClinicNames = [
    'Clinica I',
    'Clinica II',
    'Clinica III',
    'Clinica IV',
    'Clinica V',
    'Clinica Integrada Infantil',
    'Clinica de Emergência',
    'Clinica Integrada Adulto I',
    'Clinica Integrada Adulto II',
    'Clinica de DTM',
    'Clinica de Odontopediatria',
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
            _logger.warning('Erro ao processar agendamento remoto: $e');
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
        final inRange = !app.startTime.isBefore(start) && !app.startTime.isAfter(end);
        final inClinic = clinicId == null || app.clinicId == clinicId;
        return inRange && inClinic;
      }).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

      return merged;
    } catch (e) {
      _logger.warning('Falha ao buscar agendamentos remotos, usando local: $e');
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
          final nested = responseData['data'] ?? responseData['appointment'] ?? responseData['Data'];
          final json = nested is Map ? Map<String, dynamic>.from(nested) : Map<String, dynamic>.from(responseData);
          
          final parsed = _appointmentFromJson(json);
          final saved = parsed.copyWith(
            id: (json['id'] ?? json['Id'])?.toString() ?? appointment.id,
            clinicId: parsed.clinicId.isEmpty ? appointment.clinicId : parsed.clinicId,
            patientName: parsed.patientName == 'Paciente não informado' ? appointment.patientName : parsed.patientName,
          );

          await _deleteLocal(appointment.id);
          await _saveLocal(saved, true);
          return saved;
        }
      }
      return appointment;
    } catch (e) {
      _logger.severe('Erro no agendamento: $e');
      throw Exception('Falha ao salvar agendamento: $e');
    }
  }

  @override
  Future<void> updateAppointmentStatus(String id, AppointmentStatus status) async {
    try {
      await _apiClient.instance.patch('/appointments/$id/status', data: {'status': status.index + 1});
      await _updateLocalStatus(id, status, true);
    } catch (e) {
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
  Future<void> syncAppointments() async {
    final unsynced = await (_localDb.select(_localDb.appointmentsLocal)..where((t) => t.isSynced.equals(false))).get();
    for (final row in unsynced) {
      try {
        await scheduleAppointment(_mapSchemaToEntity(row));
      } catch (_) {}
    }
  }

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
    final rawStatus = json['status'] ?? json['Status'];
    AppointmentStatus status = AppointmentStatus.scheduled;
    if (rawStatus is int) {
      int idx = rawStatus >= 1 ? rawStatus - 1 : rawStatus;
      if (idx >= 0 && idx < AppointmentStatus.values.length) status = AppointmentStatus.values[idx];
    } else if (rawStatus != null) {
      status = AppointmentStatus.values.firstWhere((e) => e.name == rawStatus.toString(), orElse: () => AppointmentStatus.scheduled);
    }

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      final dt = v is DateTime ? v : DateTime.parse(v.toString());
      return dt.isUtc ? dt.toLocal() : dt;
    }

    String getString(List<String> keys) {
      for (final k in keys) {
        if (json[k] != null) return json[k].toString();
      }
      return '';
    }

    return Appointment(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      patientId: getString(['patientId', 'PatientId', 'patient_id']),
      patientName: getString(['patientName', 'PatientName', 'patient_name', 'fullName', 'FullName']),
      doctorId: getString(['doctorId', 'DoctorId', 'doctor_id']),
      doctorName: getString(['doctorName', 'DoctorName', 'doctor_name']),
      studentId: getString(['studentId', 'StudentId', 'student_id']),
      studentName: getString(['studentName', 'StudentName', 'student_name']),
      professorId: getString(['professorId', 'ProfessorId', 'professor_id']),
      professorName: getString(['professorName', 'ProfessorName', 'professor_name']),
      startTime: parseDate(json['startTime'] ?? json['StartTime'] ?? json['start']),
      endTime: parseDate(json['endTime'] ?? json['EndTime'] ?? json['end']),
      status: status,
      procedureName: getString(['procedureName', 'ProcedureName', 'procedure_name']),
      notes: getString(['notes', 'Notes', 'observation']),
      clinicId: getString(['clinicId', 'ClinicId', 'clinic_id']),
    );
  }

  Appointment _mapSchemaToEntity(dynamic row) {
    final data = row.toJson();
    return _appointmentFromJson(data);
  }
}
