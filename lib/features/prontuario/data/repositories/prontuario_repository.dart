import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart' as drift_db;
import 'package:promt/features/prontuario/domain/entities/odontogram.dart';
import 'package:promt/features/prontuario/domain/entities/prescription.dart';
import 'package:promt/features/prontuario/domain/entities/anamnese.dart';
import 'package:promt/features/prontuario/domain/entities/treatment_plan.dart';
import 'package:promt/features/prontuario/domain/entities/evolution.dart';
import 'package:promt/features/prontuario/domain/repositories/i_prontuario_repository.dart';
import 'package:promt/features/auth/domain/entities/user.dart';
import 'package:uuid/uuid.dart';

class ProntuarioRepository implements IProntuarioRepository {
  final ApiClient _apiClient;
  final drift_db.AppDatabase _localDb;
  final User? _currentUser;

  ProntuarioRepository(this._apiClient, this._localDb, [this._currentUser]);

  Future<String> _getDefaultClinicId() async {
    try {
      final response = await _apiClient.instance.get('Clinics');
      if (response.data is List && (response.data as List).isNotEmpty) {
        return response.data[0]['id'].toString();
      }
    } catch (_) {}
    return '00000000-0000-0000-0000-000000000000';
  }

  @override
  Future<Odontogram> getOdontogram(String patientId) async {
    // 1. Tenta buscar localmente primeiro (cache offline)
    final local = await (_localDb.select(_localDb.odontogramLocal)
          ..where((t) => t.patientId.equals(patientId)))
        .getSingleOrNull();

    if (local != null) {
      return Odontogram.fromJson(jsonDecode(local.dataJson));
    }

    // 2. Se não houver local, busca na API
    try {
      final response = await _apiClient.instance.get('Prontuario/$patientId/odontogram');
      if (response.data == null || response.data == 'null') return _initialOdontogram(patientId);
      
      final jsonData = response.data is String ? jsonDecode(response.data) : response.data;
      final odontogram = Odontogram.fromJson(jsonData);
      
      // Cacheia localmente
      await _saveLocalOdontogram(odontogram, true);
      return odontogram;
    } catch (_) {
      return _initialOdontogram(patientId);
    }
  }

  Odontogram _initialOdontogram(String patientId) => Odontogram(
    id: const Uuid().v4(),
    patientId: patientId,
    teeth: [],
    updatedAt: DateTime.now(),
    updatedBy: _currentUser?.id ?? 'system',
  );

  @override
  Future<void> saveOdontogram(Odontogram odontogram) async {
    // 1. Salva localmente marcando como não sincronizado
    await _saveLocalOdontogram(odontogram, false);

    // 2. Tenta enviar para a API se o paciente estiver sincronizado
    try {
      final patient = await (_localDb.select(_localDb.patients)
            ..where((t) => t.id.equals(odontogram.patientId)))
          .getSingleOrNull();

      if (patient != null && patient.isSynced) {
        await _sendOdontogramToApi(odontogram);
        await _saveLocalOdontogram(odontogram, true);
      } else {
        debugPrint('Odontograma salvo localmente. Aguardando sincronização do paciente.');
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar odontograma: $e');
    }
  }

  Future<void> _sendOdontogramToApi(Odontogram odontogram) async {
    final data = {
      'patientId': odontogram.patientId,
      'teeth': odontogram.teeth.map((t) => {
        'toothNumber': t.toothNumber,
        'surfaces': t.surfaces.map((s) => s.name.substring(0, 1).toUpperCase() + s.name.substring(1)).toList(),
        'condition': t.condition.name.substring(0, 1).toUpperCase() + t.condition.name.substring(1),
        'observation': t.observation
      }).toList(),
    };
    await _apiClient.instance.post('Prontuario/odontogram', data: data);
  }

  Future<void> _saveLocalOdontogram(Odontogram odontogram, bool isSynced) async {
    await _localDb.into(_localDb.odontogramLocal).insertOnConflictUpdate(
      drift_db.OdontogramLocalCompanion.insert(
        patientId: odontogram.patientId,
        dataJson: jsonEncode(odontogram.toJson()),
        lastUpdated: DateTime.now(),
        isSynced: Value(isSynced),
      ),
    );
  }

  @override
  Future<void> syncPendingData() async {
    // 1. Sincroniza Odontogramas pendentes
    final pendingOdontograms = await (_localDb.select(_localDb.odontogramLocal)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    for (final row in pendingOdontograms) {
      try {
        // Verifica se o paciente já foi sincronizado primeiro
        final patient = await (_localDb.select(_localDb.patients)
              ..where((t) => t.id.equals(row.patientId)))
            .getSingleOrNull();

        if (patient != null && patient.isSynced) {
          final odontogram = Odontogram.fromJson(jsonDecode(row.dataJson));
          await _sendOdontogramToApi(odontogram);
          
          await (_localDb.update(_localDb.odontogramLocal)
                ..where((t) => t.patientId.equals(row.patientId)))
              .write(const drift_db.OdontogramLocalCompanion(isSynced: Value(true)));
        }
      } catch (e) {
        debugPrint('Falha ao sincronizar odontograma pendente do paciente ${row.patientId}: $e');
      }
    }
    
    // TODO: Implementar sincronização de Evoluções, Receitas etc.
  }

  @override
  Future<void> saveTreatmentPlan(TreatmentPlan plan) async {
    final data = {
      'patientId': plan.patientId,
      'description': plan.description,
      'items': plan.items.map((i) => {
        'procedureId': i.procedureId,
        'procedureName': i.procedureName,
        'toothNumber': i.toothNumber,
        'observation': i.observation
      }).toList(),
    };
    await _apiClient.instance.post('TreatmentPlans', data: data);
  }

  @override
  Future<Prescription> createPrescription(Prescription prescription) async {
    final clinicId = await _getDefaultClinicId();
    final data = {
      'patientId': prescription.patientId,
      'clinicId': clinicId,
      'observations': prescription.observations,
      'items': prescription.items.map((i) => {
        'medicineName': i.medicineName,
        'dosage': i.dosage,
        'instructions': i.instructions
      }).toList(),
    };
    final response = await _apiClient.instance.post('Documentos/receitas', data: data);
    return Prescription.fromJson(response.data);
  }

  @override
  Future<MedicalCertificate> createCertificate(MedicalCertificate certificate) async {
    final clinicId = await _getDefaultClinicId();
    final data = {
      'patientId': certificate.patientId,
      'clinicId': clinicId,
      'content': certificate.content,
      'daysOfRest': certificate.daysOfRest,
      'cid': certificate.cid
    };
    final response = await _apiClient.instance.post('Documentos/atestados', data: data);
    return MedicalCertificate.fromJson(response.data);
  }

  @override
  Future<List<Prescription>> getPrescriptionHistory(String patientId) async {
    try {
      final response = await _apiClient.instance.get('Documentos/receitas/$patientId');
      return (response.data as List).map((json) => Prescription.fromJson(json)).toList();
    } catch (_) { return []; }
  }

  @override
  Future<List<MedicalCertificate>> getCertificateHistory(String patientId) async {
    try {
      final response = await _apiClient.instance.get('Documentos/atestados/$patientId');
      return (response.data as List).map((json) => MedicalCertificate.fromJson(json)).toList();
    } catch (_) { return []; }
  }

  @override
  Future<List<Anamnese>> getAnamneses(String patientId) async {
    try {
      final response = await _apiClient.instance.get('Prontuario/$patientId/anamnese');
      if (response.data == null) return [];
      return [Anamnese.fromJson(response.data)];
    } catch (_) { return []; }
  }

  @override
  Future<void> addEvolution(String patientId, String description, String professorId) async {
    await _apiClient.instance.post('Evolutions', data: {
      'patientId': patientId,
      'description': description,
      'professorId': professorId,
    });
  }

  @override
  Future<List<Evolution>> getEvolutions(String patientId) async {
    try {
      final response = await _apiClient.instance.get('Prontuario/$patientId/evolutions');
      return (response.data as List).map((json) => Evolution.fromJson(json)).toList();
    } catch (_) { return []; }
  }

  @override
  Future<void> signEvolution(String evolutionId) async {
    await _apiClient.instance.post('Evolutions/$evolutionId/sign', data: {});
  }

  @override Future<Anamnese?> getAnamneseByPatientId(String id) async {
    final results = await getAnamneses(id);
    return results.isNotEmpty ? results.first : null;
  }
  @override Future<void> saveAnamnese(String id, Map<String, dynamic> r) async {
    await _apiClient.instance.post('Prontuario/$id/anamnese', data: r);
  }

  @override
  Future<Map<String, dynamic>?> getEndodontia(String patientId) async {
    // 1. Tenta recuperar localmente primeiro (Cache imediato)
    try {
      final local = await (_localDb.select(_localDb.odontogramLocal)
            ..where((t) => t.patientId.equals('endo_$patientId')))
          .getSingleOrNull();
      if (local != null) return jsonDecode(local.dataJson);
    } catch (_) {}

    // 2. Busca na API
    try {
      final response = await _apiClient.instance.get('Prontuario/$patientId/endodontia');
      if (response.data == null || response.data == "") return null;
      
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      await _saveLocalEndo(patientId, data);
      return data;
    } catch (_) { return null; }
  }

  @override
  Future<void> saveEndodontia(String patientId, Map<String, dynamic> data) async {
    // 1. Salva localmente marcando como não sincronizado
    await _saveLocalEndo(patientId, data);

    // 2. Envia para a API
    try {
      await _apiClient.instance.post('Prontuario/$patientId/endodontia', data: data);
    } catch (e) {
      debugPrint('Endodontia salva localmente. Erro ao sincronizar: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getPeriograma(String patientId) async {
    try {
      final local = await (_localDb.select(_localDb.odontogramLocal)
            ..where((t) => t.patientId.equals('peri_$patientId')))
          .getSingleOrNull();
      if (local != null) return jsonDecode(local.dataJson);
    } catch (_) {}

    try {
      final response = await _apiClient.instance.get('Prontuario/$patientId/periograma');
      if (response.data == null || response.data == "") return null;
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      await _saveLocalPeri(patientId, data);
      return data;
    } catch (_) { return null; }
  }

  @override
  Future<void> savePeriograma(String patientId, Map<String, dynamic> data) async {
    await _saveLocalPeri(patientId, data);
    try {
      await _apiClient.instance.post('Prontuario/$patientId/periograma', data: data);
    } catch (e) {
      debugPrint('Periograma salvo localmente. Erro ao sincronizar: $e');
    }
  }

  Future<void> _saveLocalPeri(String patientId, Map<String, dynamic> data) async {
    await _localDb.into(_localDb.odontogramLocal).insertOnConflictUpdate(
      drift_db.OdontogramLocalCompanion.insert(
        patientId: 'peri_$patientId',
        dataJson: jsonEncode(data),
        lastUpdated: DateTime.now(),
        isSynced: const Value(true),
      ),
    );
  }

  Future<void> _saveLocalEndo(String patientId, Map<String, dynamic> data) async {
    // Reutiliza a tabela de Odontograma com prefixo no ID para persistência sem migração de banco
    await _localDb.into(_localDb.odontogramLocal).insertOnConflictUpdate(
      drift_db.OdontogramLocalCompanion.insert(
        patientId: 'endo_$patientId',
        dataJson: jsonEncode(data),
        lastUpdated: DateTime.now(),
        isSynced: const Value(true),
      ),
    );
  }

  @override Future<List<Evolution>> getEvolutionHistory(String id) async => getEvolutions(id);
  @override Future<List<TreatmentPlan>> getTreatmentPlans(String id) async {
    try {
      final response = await _apiClient.instance.get('TreatmentPlans/active/$id');
      return [TreatmentPlan.fromJson(response.data)];
    } catch (_) { return []; }
  }
  @override Future<TreatmentPlan?> getTreatmentPlan(String id) async {
    final results = await getTreatmentPlans(id);
    return results.isNotEmpty ? results.first : null;
  }
  @override Future<void> updateTreatmentItemStatus(String p, String i, String s) async {}
}
