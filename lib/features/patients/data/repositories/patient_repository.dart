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
    final selectQuery = _localDb.select(_localDb.patientsLocal);
    if (query != null && query.isNotEmpty) {
      selectQuery.where(
        (t) => t.fullName.contains(query) | t.cpf.contains(query),
      );
    }
    selectQuery.orderBy([(t) => OrderingTerm(expression: t.fullName)]);
    final results = await selectQuery.get();
    return results.map((row) => _mapSchemaToEntity(row)).toList();
  }

  @override
  Future<entity.Patient> createPatient(entity.Patient patient) async {
    final id = patient.id.isEmpty ? _uuid.v4() : patient.id;
    final patientWithId = patient.copyWith(id: id);

    await _saveLocal(patientWithId, false);

    // CORRECAO: o erro de sincronizacao nao e mais engolido silenciosamente.
    // Antes, uma falha no POST (ex.: validacao do servidor) deixava o paciente
    // apenas no banco local e o agendamento falhava depois com "paciente nao
    // existe no servidor", sem nenhuma mensagem para o usuario.
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
        message =
            data['message']?.toString() ??
            data['title']?.toString() ??
            data['error']?.toString();
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final details = errors.entries
              .map((entry) {
                final value = entry.value;
                final text = value is List
                    ? value.join('; ')
                    : value.toString();
                return text.isEmpty ? entry.key.toString() : '$text';
              })
              .join('; ');
          if (details.isNotEmpty) message = details;
        }
      } else if (data != null) {
        message = data.toString();
      }
      throw Exception(
        message?.trim().isNotEmpty == true
            ? message
            : 'Falha ao salvar o paciente no servidor',
      );
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

      if (response.statusCode == 200 || response.statusCode == 204) {
        await (_localDb.update(
          _localDb.patientsLocal,
        )..where((t) => t.id.equals(patient.id))).write(
          const drift_db.PatientsLocalCompanion(isSynced: Value(true)),
        );
      }
    } catch (e) {
      debugPrint('Erro ao atualizar paciente na API: $e');
    }
  }

  @override
  Future<void> syncPatients() async {
    final pendingPatients = await (_localDb.select(
      _localDb.patientsLocal,
    )..where((t) => t.isSynced.equals(false))).get();

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

        if (response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 204) {
          await (_localDb.update(
            _localDb.patientsLocal,
          )..where((t) => t.id.equals(row.id))).write(
            const drift_db.PatientsLocalCompanion(isSynced: Value(true)),
          );
        }
      } catch (e) {
        debugPrint('Falha ao sincronizar paciente ${row.fullName}: $e');
      }
    }

    try {
      final response = await _apiClient.instance.get('patients');
      if (response.data != null) {
        final data = response.data;
        final List<dynamic> items = data is Map ? (data['items'] ?? []) : data;
        final remotePatients = items
            .map((json) => _mapJsonToEntity(json))
            .toList();
        await _updateLocalCache(remotePatients);
      }
    } catch (e) {
      debugPrint('Falha ao buscar pacientes atualizados do servidor: $e');
    }
  }

  entity.Patient _mapJsonToEntity(Map<String, dynamic> json) {
    return entity.Patient(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? 'Sem Nome',
      socialName:
          json['socialName'] as String? ?? json['SocialName'] as String?,
      cpf: json['cpf'] ?? '',
      susNumber: json['susNumber'] as String? ?? json['SusNumber'] as String?,
      birthDate: DateTime.parse(
        json['birthDate'] ?? DateTime.now().toIso8601String(),
      ),
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      lgpdConsent: json['lgpdConsent'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // CORREÇÃO: O tipo gerado para a tabela PatientsLocal com @DataClassName('PatientLocal') é drift_db.PatientLocal
  entity.Patient _mapSchemaToEntity(drift_db.PatientLocal row) {
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
      'Email': patient.email?.trim().isEmpty == true ? null : patient.email,
      'Phone': patient.phone?.trim().isEmpty == true ? null : patient.phone,
      'BirthDate': patient.birthDate.toIso8601String(),
      'Gender': patient.gender,
      'LgpdConsent': patient.lgpdConsent,
      'IsActive': true,
      'CreatedAt': patient.createdAt.toIso8601String(),
    };
  }

  Future<void> _saveLocal(entity.Patient patient, bool isSynced) async {
    await _localDb
        .into(_localDb.patientsLocal)
        .insertOnConflictUpdate(
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
  Future<entity.Patient> getPatientById(String id) async =>
      (await getLocalPatients()).firstWhere((p) => p.id == id);

  @override
  Future<List<PatientChangeLog>> getPatientHistory(String patientId) async {
    try {
      final response = await _apiClient.instance.get(
        'patients/$patientId/history',
      );
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
