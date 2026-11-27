import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
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
  final _logger = Logger('ProntuarioRepository');

  ProntuarioRepository(this._apiClient, this._localDb, [this._currentUser]);

  static const _emptyGuid = '00000000-0000-0000-0000-000000000000';

  /// Extrai (sheetType, realPatientId) a partir de chaves prefixadas usadas
  /// nas fichas clínicas (ex.: `anamnese_<uuid>`, `ppr_<uuid>`, `tcle_<uuid>`).
  (String sheetType, String realPatientId) _parseSheetKey(String key) {
    const knownPrefixes = [
      'anamnese_',
      'extraoral_',
      'intraoral_',
      'periograma_',
      'endodontia_',
      'ppr_',
      'dtm_',
      'odontopediatria_',
      'tcle_',
    ];
    for (final prefix in knownPrefixes) {
      if (key.startsWith(prefix)) {
        final type = prefix.substring(0, prefix.length - 1);
        return (type, key.substring(prefix.length));
      }
    }
    return ('endodontia', key);
  }

  Future<String> _resolveClinicId(String? preferredClinicId) async {
    if (preferredClinicId != null &&
        preferredClinicId.isNotEmpty &&
        preferredClinicId != _emptyGuid) {
      return preferredClinicId;
    }
    try {
      final response = await _apiClient.instance.get('Clinics');
      if (response.data is List && (response.data as List).isNotEmpty) {
        return response.data[0]['id'].toString();
      }
    } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }
    return _emptyGuid;
  }

  @override
  Future<Odontogram> getOdontogram(String patientId) async {
    try {
      final response = await _apiClient.instance.get('Prontuario/$patientId/odontogram');
      if (response.data != null && response.data != 'null' && response.data != '') {
        final jsonData = response.data is String ? jsonDecode(response.data) : response.data;
        if (jsonData is Map) {
          final odontogram = Odontogram.fromJson(Map<String, dynamic>.from(jsonData));
          await _saveLocalOdontogram(odontogram, true);
          return odontogram;
        }
      }
    } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }

    try {
      final local = await (_localDb.select(_localDb.odontogramLocal)
            ..where((t) => t.patientId.equals(patientId)))
          .getSingleOrNull();

      if (local != null) {
        return Odontogram.fromJson(jsonDecode(local.dataJson));
      }
    } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }

    return _initialOdontogram(patientId);
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
    await _saveLocalOdontogram(odontogram, false);

    try {
      await _sendOdontogramToApi(odontogram);
      await _saveLocalOdontogram(odontogram, true);
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
        'observation': t.observation,
      }).toList(),
    };
    await _apiClient.instance.post('Prontuario/odontogram', data: data);
  }

  Future<void> _saveLocalOdontogram(Odontogram odontogram, bool isSynced) async {
    await _localDb.into(_localDb.odontogramLocal).insertOnConflictUpdate(
      drift_db.OdontogramLocalCompanion(
        patientId: Value(odontogram.patientId),
        dataJson: Value(jsonEncode({
          'id': odontogram.id,
          'patientId': odontogram.patientId,
          'teeth': odontogram.teeth.map((t) => {
            'toothNumber': t.toothNumber,
            'surfaces': t.surfaces.map((s) => s.name).toList(),
            'condition': t.condition.name,
            'observation': t.observation,
          }).toList(),
          'updatedAt': odontogram.updatedAt.toIso8601String(),
          'updatedBy': odontogram.updatedBy,
        })),
        lastUpdated: Value(DateTime.now()),
        isSynced: Value(isSynced),
      ),
    );
  }

  @override
  Future<void> syncPendingData() async {
    try {
      final pendingRows = await (_localDb.select(_localDb.odontogramLocal)
            ..where((t) => t.isSynced.equals(false)))
          .get();

      for (final row in pendingRows) {
        try {
          if (row.patientId.startsWith('endo_')) {
            final rawKey = row.patientId.substring('endo_'.length);
            final (sheetType, realId) = _parseSheetKey(rawKey);
            await _apiClient.instance.post(
              'Prontuario/$realId/fichas/$sheetType',
              data: jsonDecode(row.dataJson),
            );
          } else if (row.patientId.startsWith('peri_')) {
            final realId = row.patientId.substring('peri_'.length);
            await _apiClient.instance.post(
              'Prontuario/$realId/fichas/periograma',
              data: jsonDecode(row.dataJson),
            );
          } else {
            final odontogram = Odontogram.fromJson(jsonDecode(row.dataJson));
            await _sendOdontogramToApi(odontogram);
          }

          await (_localDb.update(_localDb.odontogramLocal)
                ..where((t) => t.patientId.equals(row.patientId)))
              .write(const drift_db.OdontogramLocalCompanion(isSynced: Value(true)));
        } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }
      }
    } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }
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
        'observation': i.observation,
        'value': 0,
      }).toList(),
    };
    await _apiClient.instance.post('TreatmentPlans', data: data);
  }

  @override
  Future<TreatmentPlan?> updateTreatmentItemStatus(
    String planId,
    String itemId,
    String status,
  ) async {
    final response = await _apiClient.instance.patch(
      'TreatmentPlans/$planId/items/$itemId/status',
      data: {'status': status},
    );
    if (response.data is Map) {
      return TreatmentPlan.fromJson(Map<String, dynamic>.from(response.data));
    }
    return null;
  }

  @override
  Future<TreatmentPlan?> approveTreatmentPlan(String planId) async {
    final response = await _apiClient.instance.patch('TreatmentPlans/$planId/approve');
    if (response.data is Map) {
      return TreatmentPlan.fromJson(Map<String, dynamic>.from(response.data));
    }
    return null;
  }

  @override
  Future<TreatmentPlan?> removeTreatmentItem(String planId, String itemId) async {
    final response = await _apiClient.instance.delete('TreatmentPlans/$planId/items/$itemId');
    if (response.data is Map) {
      return TreatmentPlan.fromJson(Map<String, dynamic>.from(response.data));
    }
    return null;
  }

  @override
  Future<Prescription> createPrescription(Prescription prescription) async {
    final clinicId = await _resolveClinicId(prescription.clinicId);
    final data = {
      'patientId': prescription.patientId,
      'clinicId': clinicId,
      'observations': prescription.observations,
      'items': prescription.items.map((i) => {
        'medicineName': i.medicineName,
        'dosage': i.dosage,
        'instructions': i.instructions,
      }).toList(),
    };
    final response = await _apiClient.instance.post('Documentos/receitas', data: data);
    return Prescription.fromJson(Map<String, dynamic>.from(response.data));
  }

  @override
  Future<MedicalCertificate> createCertificate(MedicalCertificate certificate) async {
    final clinicId = await _resolveClinicId(null);
    final data = {
      'patientId': certificate.patientId,
      'clinicId': clinicId,
      'content': certificate.content,
      'daysOfRest': certificate.daysOfRest,
      'cid': certificate.cid,
    };
    final response = await _apiClient.instance.post('Documentos/atestados', data: data);
    return MedicalCertificate.fromJson(Map<String, dynamic>.from(response.data));
  }

  @override
  Future<List<Prescription>> getPrescriptionHistory(String patientId) async {
    try {
      final response = await _apiClient.instance.get('Documentos/receitas/$patientId');
      return (response.data as List)
          .whereType<Map>()
          .map((json) => Prescription.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<MedicalCertificate>> getCertificateHistory(String patientId) async {
    try {
      final response = await _apiClient.instance.get('Documentos/atestados/$patientId');
      return (response.data as List)
          .whereType<Map>()
          .map((json) => MedicalCertificate.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Anamnese>> getAnamneses(String patientId) async {
    try {
      final response = await _apiClient.instance.get('Prontuario/$patientId/anamnese');
      if (response.data != null) {
        await _saveLocalAnamnese(
          patientId,
          response.data is Map ? Map<String, dynamic>.from(response.data) : <String, dynamic>{},
          true,
        );
        return [Anamnese.fromJson(Map<String, dynamic>.from(response.data))];
      }
    } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }

    final local = await (_localDb.select(_localDb.anamneseLocal)
          ..where((t) => t.patientId.equals(patientId)))
        .getSingleOrNull();
    if (local == null) return [];
    try {
      return [Anamnese.fromJson(jsonDecode(local.responsesJson))];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addEvolution(
    String patientId,
    String description,
    String professorId, {
    String? clinicId,
  }) async {
    await _apiClient.instance.post('Evolutions', data: {
      'patientId': patientId,
      'description': description,
      if (professorId.isNotEmpty) 'professorId': professorId,
      if (clinicId != null && clinicId.isNotEmpty) 'clinicId': clinicId,
    });
  }

  @override
  Future<List<Evolution>> getEvolutions(String patientId) async {
    try {
      final response = await _apiClient.instance.get('Prontuario/$patientId/evolutions');
      return (response.data as List)
          .whereType<Map>()
          .map((json) => Evolution.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> signEvolution(String evolutionId) async {
    await _apiClient.instance.post('Evolutions/$evolutionId/sign', data: {});
  }

  @override
  Future<Anamnese?> getAnamneseByPatientId(String id) async {
    final results = await getAnamneses(id);
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<void> saveAnamnese(String id, Map<String, dynamic> r) async {
    await _saveLocalAnamnese(id, r, false);
    try {
      await _apiClient.instance.post('Prontuario/$id/anamnese', data: r);
      await _saveLocalAnamnese(id, r, true);
    } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }
  }

  Future<void> _saveLocalAnamnese(
    String patientId,
    Map<String, dynamic> responses,
    bool isSynced,
  ) async {
    await _localDb.into(_localDb.anamneseLocal).insertOnConflictUpdate(
      drift_db.AnamneseLocalCompanion(
        patientId: Value(patientId),
        responsesJson: Value(jsonEncode(responses)),
        lastUpdated: Value(DateTime.now()),
        isSynced: Value(isSynced),
      ),
    );
  }

  @override
  Future<Map<String, dynamic>?> getEndodontia(String patientId) async {
    final (sheetType, realPatientId) = _parseSheetKey(patientId);

    try {
      final response = await _apiClient.instance.get(
        'Prontuario/$realPatientId/fichas/$sheetType',
      );
      if (response.data != null && response.data != '') {
        final decoded = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        if (decoded is Map) {
          final map = Map<String, dynamic>.from(decoded);
          await _saveLocalEndo(patientId, map, isSynced: true);
          return map;
        }
      }
    } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }

    try {
      final local = await (_localDb.select(_localDb.odontogramLocal)
            ..where((t) => t.patientId.equals('endo_$patientId')))
          .getSingleOrNull();
      if (local != null) {
        final decoded = jsonDecode(local.dataJson);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }

    return null;
  }

  @override
  Future<void> saveEndodontia(String patientId, Map<String, dynamic> data) async {
    final (sheetType, realPatientId) = _parseSheetKey(patientId);
    await _saveLocalEndo(patientId, data, isSynced: false);
    try {
      await _apiClient.instance.post(
        'Prontuario/$realPatientId/fichas/$sheetType',
        data: data,
      );
      await _saveLocalEndo(patientId, data, isSynced: true);
    } catch (e) {
      debugPrint('Ficha $sheetType salva localmente. Erro ao sincronizar: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getPeriograma(String patientId) async {
    try {
      final response = await _apiClient.instance.get(
        'Prontuario/$patientId/fichas/periograma',
      );
      if (response.data != null && response.data != '') {
        final decoded = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        if (decoded is Map) {
          final map = Map<String, dynamic>.from(decoded);
          await _saveLocalPeri(patientId, map, isSynced: true);
          return map;
        }
      }
    } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }

    try {
      final local = await (_localDb.select(_localDb.odontogramLocal)
            ..where((t) => t.patientId.equals('peri_$patientId')))
          .getSingleOrNull();
      if (local != null) {
        final decoded = jsonDecode(local.dataJson);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }

    return null;
  }

  @override
  Future<void> savePeriograma(String patientId, Map<String, dynamic> data) async {
    await _saveLocalPeri(patientId, data, isSynced: false);
    try {
      await _apiClient.instance.post(
        'Prontuario/$patientId/fichas/periograma',
        data: data,
      );
      await _saveLocalPeri(patientId, data, isSynced: true);
    } catch (e) {
      debugPrint('Periograma salvo localmente. Erro ao sincronizar: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getClinicalSheetHistory(
    String patientId,
    String sheetType,
  ) async {
    try {
      final response = await _apiClient.instance.get(
        'Prontuario/$patientId/fichas/$sheetType/history',
      );
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getProntuarioSummary(String patientId) async {
    try {
      final response = await _apiClient.instance.get('Prontuario/$patientId/summary');
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }

    // Fallback offline usando o cache SQLite local
    final sheets = <String, dynamic>{};
    final localRows = await _localDb.select(_localDb.odontogramLocal).get();
    for (final row in localRows) {
      if (row.patientId == 'peri_$patientId') {
        sheets['periograma'] = {'version': 1, 'updatedAt': row.lastUpdated.toIso8601String()};
      } else if (row.patientId.startsWith('endo_')) {
        final key = row.patientId.substring('endo_'.length);
        final (type, realId) = _parseSheetKey(key);
        if (realId == patientId) {
          sheets[type] = {'version': 1, 'updatedAt': row.lastUpdated.toIso8601String()};
        }
      }
    }
    return {'sheets': sheets};
  }

  @override
  Future<List<Map<String, dynamic>>> getClinicalTimeline(String patientId) async {
    try {
      final response = await _apiClient.instance.get('Prontuario/$patientId/timeline');
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      _logger.warning('Falha de sincronização/leitura no prontuário: $e');
    }
    return [];
  }

  Future<void> _saveLocalPeri(
    String patientId,
    Map<String, dynamic> data, {
    bool isSynced = true,
  }) async {
    await _localDb.into(_localDb.odontogramLocal).insertOnConflictUpdate(
      drift_db.OdontogramLocalCompanion(
        patientId: Value('peri_$patientId'),
        dataJson: Value(jsonEncode(data)),
        lastUpdated: Value(DateTime.now()),
        isSynced: Value(isSynced),
      ),
    );
  }

  Future<void> _saveLocalEndo(
    String patientId,
    Map<String, dynamic> data, {
    bool isSynced = true,
  }) async {
    await _localDb.into(_localDb.odontogramLocal).insertOnConflictUpdate(
      drift_db.OdontogramLocalCompanion(
        patientId: Value('endo_$patientId'),
        dataJson: Value(jsonEncode(data)),
        lastUpdated: Value(DateTime.now()),
        isSynced: Value(isSynced),
      ),
    );
  }

  Future<List<Evolution>> getEvolutionHistory(String id) async => getEvolutions(id);

  @override
  Future<List<TreatmentPlan>> getTreatmentPlans(String id) async {
    try {
      final response = await _apiClient.instance.get('TreatmentPlans/active/$id');
      if (response.data is Map) {
        return [TreatmentPlan.fromJson(Map<String, dynamic>.from(response.data))];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<TreatmentPlan?> getTreatmentPlan(String id) async {
    final results = await getTreatmentPlans(id);
    return results.isNotEmpty ? results.first : null;
  }
}
