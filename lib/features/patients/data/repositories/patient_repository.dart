import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart' as drift_db;
import 'package:promt/features/patients/domain/entities/patient.dart' as entity;
import 'package:promt/features/patients/domain/repositories/i_patient_repository.dart';
import 'package:promt/features/patients/domain/entities/patient_change_log.dart';
import 'package:uuid/uuid.dart';

class PatientRepository implements IPatientRepository {
  final ApiClient _apiClient;
  final drift_db.AppDatabase _localDb;
  final _uuid = const Uuid();

  PatientRepository(this._apiClient, this._localDb);

  DateTime _safeParseDate(dynamic v) {
    if (v == null || v.toString().trim().isEmpty || v.toString() == 'null') {
      return DateTime.now();
    }
    try {
      if (v is DateTime) return v.isUtc ? v.toLocal() : v;
      final s = v.toString();
      final dateStr = s.contains('T') || s.contains(' ') ? s : '${s}T00:00:00';
      final dt = DateTime.parse(dateStr);
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Future<List<entity.Patient>> getPatients({
    int page = 1,
    String? query,
  }) async {
    try {
      final response = await _apiClient.instance.get(
        'patients',
        queryParameters: {'page': page, 'search': query},
      );

      if (response.data != null) {
        final data = response.data;
        final List<dynamic> items = data is Map ? (data['items'] ?? []) : data;
        final apiPatients = items
            .map((json) => _mapJsonToEntity(json))
            .toList();
        await _updateLocalCache(apiPatients);
      }
    } catch (e) {
      debugPrint('Erro ao buscar pacientes na API: $e');
    }
    return getLocalPatients(query: query);
  }

  @override
  Future<List<entity.Patient>> getLocalPatients({String? query}) async {
    final dynamic db = _localDb;
    final selectQuery = db.select(db.patientsLocal);
    if (query != null && query.isNotEmpty) {
      selectQuery.where(
        (t) => (t as dynamic).fullName.contains(query) | (t as dynamic).cpf.contains(query),
      );
    }
    selectQuery.orderBy([(t) => OrderingTerm(expression: (t as dynamic).fullName)]);
    final results = await selectQuery.get();
    return results.map((row) => _mapSchemaToEntity(row)).toList();
  }

  @override
  Future<entity.Patient> createPatient(entity.Patient patient) async {
    final id = patient.id.isEmpty ? _uuid.v4() : patient.id;
    final patientWithId = patient.copyWith(id: id);

    await _saveLocal(patientWithId, false);

    Response response;
    try {
      response = await _apiClient.instance.post(
        'patients',
        data: _mapEntityToJson(patientWithId),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      String? message;
      if (data is Map) {
        message = data['message']?.toString() ?? data['title']?.toString() ?? data['error']?.toString();
      }
      throw Exception(message ?? 'Falha ao salvar o paciente no servidor');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      await _saveLocal(patientWithId, true);
      final body = response.data;
      if (body is Map<String, dynamic>) {
        return _mapJsonToEntity(body);
      }
    }
    return patientWithId;
  }

  @override
  Future<void> updatePatient(entity.Patient patient) async {
    await _saveLocal(patient, false);
    try {
      final response = await _apiClient.instance.put(
        'patients/${patient.id}',
        data: {'Patient': _mapEntityToJson(patient)},
      );
      final dynamic db = _localDb;
      if (response.statusCode == 200 || response.statusCode == 204) {
        await (db.update(db.patientsLocal)..where((t) => (t as dynamic).id.equals(patient.id))).write(
          drift_db.PatientsLocalCompanion(isSynced: const Value(true)),
        );
      }
    } catch (e) {
      debugPrint('Erro ao atualizar paciente na API: $e');
    }
  }

  @override
  Future<void> syncPatients() async {
    final dynamic db = _localDb;
    final pendingPatients = await (db.select(db.patientsLocal)..where((t) => (t as dynamic).isSynced.equals(false))).get();
    for (final row in pendingPatients) {
      try {
        final patientEntity = _mapSchemaToEntity(row);
        Response response;
        try {
          response = await _apiClient.instance.put('patients/${(row as dynamic).id}', data: _mapEntityToJson(patientEntity));
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) {
            response = await _apiClient.instance.post('patients', data: _mapEntityToJson(patientEntity));
          } else {
            rethrow;
          }
        }
        if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
          await (db.update(db.patientsLocal)..where((t) => (t as dynamic).id.equals((row as dynamic).id))).write(
            drift_db.PatientsLocalCompanion(isSynced: const Value(true)),
          );
        }
      } catch (e) {
        debugPrint('Falha ao sincronizar paciente: $e');
      }
    }
  }

  entity.Patient _mapJsonToEntity(Map<String, dynamic> json) {
    return entity.Patient(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['FullName'] ?? 'Sem Nome',
      socialName: json['socialName'] ?? json['SocialName'],
      cpf: json['cpf'] ?? json['CPF'] ?? '',
      susNumber: json['susNumber'] ?? json['SusNumber'],
      birthDate: _safeParseDate(json['birthDate'] ?? json['BirthDate']),
      email: json['email'] ?? json['Email'],
      phone: json['phone'] ?? json['Phone'],
      gender: json['gender'] ?? json['Gender'],
      lgpdConsent: json['lgpdConsent'] ?? json['LgpdConsent'] ?? false,
      createdAt: _safeParseDate(json['createdAt'] ?? json['CreatedAt']),
    );
  }

  entity.Patient _mapSchemaToEntity(dynamic row) {
    return entity.Patient(
      id: row.id as String,
      fullName: row.fullName as String,
      socialName: row.socialName as String?,
      cpf: row.cpf as String,
      susNumber: row.susNumber as String?,
      birthDate: row.birthDate as DateTime,
      email: row.email as String?,
      phone: row.phone as String?,
      gender: row.gender as String?,
      lgpdConsent: row.lgpdConsent as bool,
      isSynced: row.isSynced as bool,
      createdAt: row.createdAt as DateTime,
    );
  }

  Map<String, dynamic> _mapEntityToJson(entity.Patient patient) {
    return {
      'Id': patient.id,
      'FullName': patient.fullName,
      'SocialName': patient.socialName,
      'CPF': patient.cpf,
      'SusNumber': patient.susNumber,
      'Email': patient.email,
      'Phone': patient.phone,
      'BirthDate': patient.birthDate.toIso8601String(),
      'Gender': patient.gender,
      'LgpdConsent': patient.lgpdConsent,
      'IsActive': true,
      'CreatedAt': patient.createdAt.toIso8601String(),
    };
  }

  Future<void> _saveLocal(entity.Patient patient, bool isSynced) async {
    final dynamic db = _localDb;
    await db.into(db.patientsLocal).insertOnConflictUpdate(
          drift_db.PatientsLocalCompanion.insert(
            id: patient.id,
            fullName: patient.fullName,
            socialName: Value(patient.socialName),
            cpf: patient.cpf,
            susNumber: Value(patient.susNumber),
            birthDate: patient.birthDate,
            createdAt: patient.createdAt,
            email: Value(patient.email),
            phone: Value(patient.phone),
            gender: Value(patient.gender),
            lgpdConsent: Value(patient.lgpdConsent),
            isSynced: Value(isSynced),
          ),
        );
  }

  Future<void> _updateLocalCache(List<entity.Patient> patients) async {
    for (var p in patients) {
      await _saveLocal(p, true);
    }
  }

  @override
  Future<entity.Patient> getPatientById(String id) async => (await getLocalPatients()).firstWhere((p) => p.id == id);

  @override
  Future<List<PatientChangeLog>> getPatientHistory(String patientId) async {
    try {
      final response = await _apiClient.instance.get('patients/$patientId/history');
      if (response.data != null) {
        final List<dynamic> list = response.data;
        return list.map((json) => PatientChangeLog.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }
}
