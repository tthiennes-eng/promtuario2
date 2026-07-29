import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart' as drift_db;
import 'package:promt/features/patients/domain/entities/patient.dart' as entity;
import 'package:promt/features/patients/domain/repositories/i_patient_repository.dart';

class PatientRepository implements IPatientRepository {
  final ApiClient _apiClient;
  final drift_db.AppDatabase _localDb;

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
      debugPrint('Erro ao buscar pacientes: $e');
    }
    return getLocalPatients();
  }

  @override
  Future<entity.Patient> createPatient(entity.Patient patient) async {
    // 1. Salva localmente
    await _saveLocal(patient, false);

    try {
      // 2. Envia para a API com mapeamento completo
      final response = await _apiClient.instance.post('patients', data: _mapEntityToJson(patient));
      final syncedPatient = _mapJsonToEntity(response.data);
      
      // 3. Atualiza cache com confirmação do servidor
      await _saveLocal(syncedPatient, true);
      return syncedPatient;
    } catch (e) {
      debugPrint('Erro na sincronização: $e');
      return patient;
    }
  }

  @override
  Future<List<entity.Patient>> getLocalPatients() async {
    final query = _localDb.select(_localDb.patients)
      ..orderBy([(t) => OrderingTerm(expression: t.fullName)]);
    final results = await query.get();
    return results.map((row) => _mapSchemaToEntity(row)).toList();
  }

  // Mapeamentos robustos
  entity.Patient _mapJsonToEntity(Map<String, dynamic> json) {
    return entity.Patient(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['nome_completo'] ?? 'Sem Nome',
      cpf: json['cpf'] ?? '',
      birthDate: DateTime.parse(json['birthDate'] ?? json['data_nascimento'] ?? DateTime.now().toIso8601String()),
      email: json['email'],
      phone: json['phone'] ?? json['telefone'],
      gender: json['gender'] ?? json['sexo'],
      lgpdConsent: json['lgpdConsent'] ?? json['consentimento_lgpd'] ?? false,
      createdAt: DateTime.now(),
      address: json['address'] != null ? entity.PatientAddress.fromJson(json['address']) : null,
    );
  }

  entity.Patient _mapSchemaToEntity(drift_db.Patient row) {
    return entity.Patient(
      id: row.id,
      fullName: row.fullName,
      cpf: row.cpf,
      birthDate: row.birthDate,
      email: row.email,
      phone: row.phone,
      gender: row.gender,
      lgpdConsent: row.lgpdConsent,
      isSynced: row.isSynced,
      createdAt: DateTime.now(),
      address: row.street != null ? entity.PatientAddress(
        street: row.street!,
        number: row.number!,
        neighborhood: row.neighborhood!,
        city: row.city!,
        state: row.state!,
        zipCode: row.zipCode!,
      ) : null,
    );
  }

  Map<String, dynamic> _mapEntityToJson(entity.Patient patient) {
    return {
      'id': patient.id,
      'fullName': patient.fullName,
      'cpf': patient.cpf,
      'email': patient.email,
      'phone': patient.phone,
      'birthDate': patient.birthDate.toIso8601String(),
      'lgpdConsent': patient.lgpdConsent,
      'address': patient.address?.toJson(),
    };
  }

  Future<void> _saveLocal(entity.Patient patient, bool isSynced) async {
    await _localDb.into(_localDb.patients).insertOnConflictUpdate(
      drift_db.PatientsCompanion.insert(
        id: patient.id,
        fullName: patient.fullName,
        cpf: patient.cpf,
        birthDate: patient.birthDate,
        email: Value(patient.email),
        phone: Value(patient.phone),
        gender: Value(patient.gender),
        lgpdConsent: Value(patient.lgpdConsent),
        isSynced: Value(isSynced),
        street: Value(patient.address?.street),
        number: Value(patient.address?.number),
        neighborhood: Value(patient.address?.neighborhood),
        city: Value(patient.address?.city),
        state: Value(patient.address?.state),
        zipCode: Value(patient.address?.zipCode),
      ),
    );
  }

  Future<void> _updateLocalCache(List<entity.Patient> patients) async {
    for (var p in patients) {
      await _saveLocal(p, true);
    }
  }

  @override Future<entity.Patient> getPatientById(String id) async => (await getLocalPatients()).firstWhere((p) => p.id == id);
  @override Future<void> updatePatient(entity.Patient p) async {}
  @override Future<void> syncPatients() async {}
}
