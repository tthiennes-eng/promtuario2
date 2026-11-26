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
    List<entity.Patient>? apiPatients;
    try {
      final response = await _apiClient.instance.get(
        'patients',
        queryParameters: {
          'page': page,
          'pageSize': 1000,
          if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
        },
      );

      if (response.data != null) {
        final data = response.data;
        final List<dynamic> items = data is Map
            ? (data['items'] ?? data['Items'] ?? data['data'] ?? const [])
            : (data is List ? data : const []);
        apiPatients = items
            .whereType<Map>()
            .map((json) => _mapJsonToEntity(Map<String, dynamic>.from(json)))
            .toList();
        await _updateLocalCache(
          apiPatients,
          replaceSynced: page == 1 && (query == null || query.trim().isEmpty),
        );
      }
    } catch (e) {
      debugPrint('Erro ao buscar pacientes na API: $e');
    }

    try {
      return await getLocalPatients(query: query);
    } catch (e) {
      debugPrint('Erro ao ler cache local de pacientes, recriando cache: $e');
      try {
        await _localDb.delete(_localDb.patientsLocal).go();
        if (apiPatients != null) {
          await _updateLocalCache(apiPatients);
          return await getLocalPatients(query: query);
        }
      } catch (resetError) {
        debugPrint('Erro ao limpar cache local de pacientes: $resetError');
      }
      return apiPatients ?? const <entity.Patient>[];
    }
  }

  @override
  Future<List<entity.Patient>> getLocalPatients({String? query}) async {
    final selectQuery = _localDb.select(_localDb.patientsLocal);
    if (query != null && query.trim().isNotEmpty) {
      final trimmed = query.trim();
      selectQuery.where(
        (t) => t.fullName.contains(trimmed) | t.cpf.contains(trimmed),
      );
    }
    selectQuery.orderBy([(t) => OrderingTerm(expression: t.fullName)]);
    final results = await selectQuery.get();
    return results.map(_mapSchemaToEntity).toList();
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
        data: _mapEntityToJson(patient),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        await (_localDb.update(_localDb.patientsLocal)
              ..where((t) => t.id.equals(patient.id)))
            .write(const drift_db.PatientsLocalCompanion(isSynced: Value(true)));
      }
    } catch (e) {
      debugPrint('Erro ao atualizar paciente na API: $e');
    }
  }

  @override
  Future<void> syncPatients() async {
    final pendingPatients = await (_localDb.select(_localDb.patientsLocal)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    for (final row in pendingPatients) {
      try {
        final patientEntity = _mapSchemaToEntity(row);
        Response response;
        try {
          response = await _apiClient.instance.put(
            'patients/${row.id}',
            data: _mapEntityToJson(patientEntity),
          );
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) {
            response = await _apiClient.instance.post(
              'patients',
              data: _mapEntityToJson(patientEntity),
            );
          } else {
            rethrow;
          }
        }
        if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
          await (_localDb.update(_localDb.patientsLocal)
                ..where((t) => t.id.equals(row.id)))
              .write(const drift_db.PatientsLocalCompanion(isSynced: Value(true)));
        }
      } catch (e) {
        debugPrint('Falha ao sincronizar paciente: $e');
      }
    }
  }

  entity.Patient _mapJsonToEntity(Map<String, dynamic> json) {
    return entity.Patient(
      id: json['id']?.toString() ?? json['Id']?.toString() ?? '',
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

  entity.Patient _mapSchemaToEntity(drift_db.PatientLocalData row) {
    return entity.Patient(
      id: row.id,
      fullName: row.fullName,
      socialName: row.socialName,
      cpf: row.cpf,
      susNumber: row.susNumber,
      birthDate: row.birthDate,
      email: row.email,
      phone: row.phone,
      gender: row.gender,
      lgpdConsent: row.lgpdConsent,
      isSynced: row.isSynced,
      createdAt: row.createdAt,
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
    await _localDb.into(_localDb.patientsLocal).insertOnConflictUpdate(
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

  Future<void> _updateLocalCache(
    List<entity.Patient> patients, {
    bool replaceSynced = false,
  }) async {
    if (replaceSynced) {
      final remoteIds = patients.map((p) => p.id).toSet();
      final existingSynced = await (_localDb.select(_localDb.patientsLocal)
            ..where((t) => t.isSynced.equals(true)))
          .get();
      for (final row in existingSynced) {
        if (!remoteIds.contains(row.id)) {
          await _deleteLocalPatientData(row.id);
        }
      }
    }
    for (var p in patients) {
      await _saveLocal(p, true);
    }
  }

  @override
  Future<void> deletePatient(String id) async {
    try {
      await _apiClient.instance.delete('patients/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) {
        final data = e.response?.data;
        String? message;
        if (data is Map) {
          message = data['message']?.toString() ??
              data['title']?.toString() ??
              data['error']?.toString();
        }
        throw Exception(
          message ??
              'Falha ao excluir o paciente no servidor (HTTP ${e.response?.statusCode ?? "erro de rede"})',
        );
      }
    }
    await _deleteLocalPatientData(id);
  }

  Future<void> _deleteLocalPatientData(String patientId) async {
    await (_localDb.delete(_localDb.appointmentsLocal)
          ..where((t) => t.patientId.equals(patientId)))
        .go();
    await (_localDb.delete(_localDb.waitListLocal)
          ..where((t) => t.patientId.equals(patientId)))
        .go();
    await (_localDb.delete(_localDb.odontogramLocal)
          ..where(
            (t) =>
                t.patientId.equals(patientId) |
                t.patientId.equals('endo_$patientId') |
                t.patientId.equals('peri_$patientId') |
                t.patientId.equals('endo_ppr_$patientId') |
                t.patientId.equals('endo_anamnese_$patientId') |
                t.patientId.equals('endo_extraoral_$patientId') |
                t.patientId.equals('endo_intraoral_$patientId'),
          ))
        .go();
    await (_localDb.delete(_localDb.anamneseLocal)
          ..where((t) => t.patientId.equals(patientId)))
        .go();
    await (_localDb.delete(_localDb.evolutionsLocal)
          ..where((t) => t.patientId.equals(patientId)))
        .go();
    await (_localDb.delete(_localDb.attachmentsLocal)
          ..where((t) => t.patientId.equals(patientId)))
        .go();
    await (_localDb.delete(_localDb.patientsLocal)
          ..where((t) => t.id.equals(patientId)))
        .go();
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
