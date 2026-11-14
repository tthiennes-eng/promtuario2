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

  @override
  Future<List<entity.Patient>> getPatients({int page = 1, String? query}) async {
    try {
      final response = await _apiClient.instance.get('patients', queryParameters: {
        'page': page,
        'search': query,
      });

      if (response.data != null) {
        final data = response.data;
        final List<dynamic> items = data is Map ? (data['items'] ?? []) : data;
        final apiPatients = items.map((json) => _mapJsonToEntity(json)).toList();
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
    try {
      final selectQuery = db.select(db.patientsLocal);
      if (query != null && query.isNotEmpty) {
        selectQuery.where((t) => (t as dynamic).fullName.contains(query) | (t as dynamic).cpf.contains(query));
      }
      final results = await selectQuery.get();
      return (results as List).map((row) => _mapSchemaToEntity(row)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<entity.Patient> createPatient(entity.Patient patient) async {
    final id = patient.id.isEmpty ? _uuid.v4() : patient.id;
    final patientWithId = patient.copyWith(id: id);

    await _saveLocal(patientWithId, false);

    try {
      final response = await _apiClient.instance.post('patients', data: _mapEntityToJson(patientWithId));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveLocal(patientWithId, true);
        return _mapJsonToEntity(response.data);
      }
    } catch (e) {
      debugPrint('Erro na sincronização imediata: $e');
    }
    return patientWithId;
  }

  @override
  Future<void> updatePatient(entity.Patient patient) async {
    await _saveLocal(patient, false);

    try {
      final response = await _apiClient.instance.put(
        'patients/${patient.id}',
        data: {
          'Patient': _mapEntityToJson(patient),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final dynamic db = _localDb;
        await (db.update(db.patientsLocal)
              ..where((t) => (t as dynamic).id.equals(patient.id)))
            .write(Insertable.fromMap({'is_synced': true}));
      }
    } catch (e) {
      debugPrint('Erro ao atualizar paciente na API: $e');
    }
  }

  @override
  Future<void> syncPatients() async {
    final dynamic db = _localDb;
    try {
      final pendingPatients = await (db.select(db.patientsLocal)
            ..where((t) => (t as dynamic).isSynced.equals(false)))
          .get();

      for (final row in (pendingPatients as List)) {
        try {
          final patientEntity = _mapSchemaToEntity(row);
          final response = await _apiClient.instance
              .put('patients/${patientEntity.id}', data: _mapEntityToJson(patientEntity));

          if (response.statusCode == 200 || response.statusCode == 204) {
             await (db.update(db.patientsLocal)
                  ..where((t) => (t as dynamic).id.equals(patientEntity.id)))
                .write(Insertable.fromMap({'is_synced': true}));
          }
        } catch (e) {
          debugPrint('Falha ao sincronizar paciente: $e');
        }
      }
    } catch (_) {}
  }

  entity.Patient _mapJsonToEntity(Map<String, dynamic> json) {
    return entity.Patient(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? 'Sem Nome',
      cpf: json['cpf'] ?? '',
      birthDate: DateTime.parse(json['birthDate'] ?? DateTime.now().toIso8601String()),
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      lgpdConsent: json['lgpdConsent'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  entity.Patient _mapSchemaToEntity(dynamic row) {
    // Usando dynamic para evitar crash do transformador FFI no Dart 3.5
    final data = row.toJson();
    return entity.Patient(
      id: data['id'] ?? '',
      fullName: data['fullName'] ?? '',
      cpf: data['cpf'] ?? '',
      birthDate: data['birthDate'] != null ? DateTime.parse(data['birthDate']) : DateTime.now(),
      email: data['email'],
      phone: data['phone'],
      gender: data['gender'],
      lgpdConsent: data['lgpdConsent'] ?? false,
      isSynced: data['isSynced'] ?? true,
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> _mapEntityToJson(entity.Patient patient) {
    return {
      'Id': patient.id,
      'FullName': patient.fullName,
      'CPF': patient.cpf,
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
      Insertable.fromMap({
        'id': patient.id,
        'full_name': patient.fullName,
        'cpf': patient.cpf,
        'birth_date': patient.birthDate,
        'created_at': patient.createdAt,
        'email': patient.email,
        'phone': patient.phone,
        'gender': patient.gender,
        'lgpd_consent': patient.lgpdConsent,
        'is_synced': isSynced,
      }),
    );
  }

  @override Future<entity.Patient> getPatientById(String id) async => throw UnimplementedError();

  @override
  Future<List<PatientChangeLog>> getPatientHistory(String patientId) async {
    try {
      final response = await _apiClient.instance.get('patients/$patientId/history');
      if (response.data != null) {
        final List<dynamic> list = response.data;
        return list.map((json) => PatientChangeLog.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Erro ao buscar histórico: $e');
    }
    return [];
  }
}
