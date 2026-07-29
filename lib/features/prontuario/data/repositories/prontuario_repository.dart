import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart';
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
  final AppDatabase _localDb;
  final User? _currentUser;

  ProntuarioRepository(this._apiClient, this._localDb, [this._currentUser]);

  @override
  Future<Odontogram> getOdontogram(String patientId) async {
    try {
      final response = await _apiClient.instance.get('Prontuario/$patientId/odontogram');
      dynamic rawData = response.data;
      if (rawData == null || rawData == '' || rawData == 'null') return _initialOdontogram(patientId);
      
      Map<String, dynamic> jsonData = rawData is String ? jsonDecode(rawData) : Map<String, dynamic>.from(rawData);
      final odontogram = Odontogram.fromJson(jsonData);
      await _saveOdontogramLocal(odontogram);
      return odontogram;
    } catch (e) {
      final local = await (_localDb.select(_localDb.odontogramLocal)..where((t) => t.patientId.equals(patientId))).getSingleOrNull();
      return local != null ? _mapLocalToOdontogram(local) : _initialOdontogram(patientId);
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
    await _saveOdontogramLocal(odontogram, isSynced: false);
    try {
      await _apiClient.instance.post('Prontuario/${odontogram.patientId}/odontogram', data: odontogram.toJson());
      await _markOdontogramAsSynced(odontogram.patientId);
    } catch (_) {}
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
    final response = await _apiClient.instance.get('Prontuario/$patientId/evolutions');
    final List<dynamic> data = response.data ?? [];
    return data.map((json) => Evolution.fromJson(json)).toList();
  }

  @override
  Future<List<TreatmentPlan>> getTreatmentPlans(String patientId) async {
    try {
      final response = await _apiClient.instance.get('TreatmentPlans/active/$patientId');
      if (response.data == null) return [];
      return [TreatmentPlan.fromJson(response.data)];
    } catch (_) { return []; }
  }

  @override
  Future<TreatmentPlan?> getTreatmentPlan(String patientId) async {
    final plans = await getTreatmentPlans(patientId);
    return plans.isNotEmpty ? plans.first : null;
  }

  @override
  Future<void> saveTreatmentPlan(TreatmentPlan plan) async {
    // Agora envia o objeto COMPLETO, incluindo a lista de itens/procedimentos
    await _apiClient.instance.post('TreatmentPlans', data: plan.toJson());
  }

  @override
  Future<void> updateTreatmentItemStatus(String planId, String itemId, String status) async {
    await _apiClient.instance.patch('TreatmentPlans/items/$itemId/status', data: {'status': status});
  }

  @override
  Future<Prescription> createPrescription(Prescription prescription) async {
    final response = await _apiClient.instance.post('Documentos/receitas', data: prescription.toJson());
    return Prescription.fromJson(response.data);
  }

  @override
  Future<List<Prescription>> getPrescriptionHistory(String patientId) async {
    final response = await _apiClient.instance.get('Documentos/receitas/$patientId');
    final List<dynamic> data = response.data ?? [];
    return data.map((json) => Prescription.fromJson(json)).toList();
  }

  @override
  Future<MedicalCertificate> createCertificate(MedicalCertificate certificate) async {
    final response = await _apiClient.instance.post('Documentos/atestados', data: certificate.toJson());
    return MedicalCertificate.fromJson(response.data);
  }

  @override
  Future<Anamnese?> getAnamneseByPatientId(String patientId) async {
    final response = await _apiClient.instance.get('Prontuario/$patientId/anamnese');
    if (response.data == null || response.data == '') return null;
    return Anamnese.fromJson(response.data);
  }

  @override
  Future<void> saveAnamnese(String patientId, Map<String, dynamic> responses) async {
    await _apiClient.instance.post('Prontuario/$patientId/anamnese', data: responses);
  }

  @override
  Future<void> signEvolution(String evolutionId) async {
    await _apiClient.instance.post('Evolutions/$evolutionId/sign');
  }

  @override Future<List<Anamnese>> getAnamneses(String id) async => [];
  @override Future<void> syncPendingData() async {}
  @override Future<List<Evolution>> getEvolutionHistory(String id) async => getEvolutions(id);

  Future<void> _saveOdontogramLocal(Odontogram o, {bool isSynced = true}) async {
    await _localDb.into(_localDb.odontogramLocal).insertOnConflictUpdate(OdontogramLocalCompanion.insert(
      patientId: o.patientId,
      dataJson: jsonEncode(o.toJson()),
      lastUpdated: DateTime.now(),
      isSynced: Value(isSynced),
    ));
  }

  Future<void> _markOdontogramAsSynced(String patientId) async {
    await (_localDb.update(_localDb.odontogramLocal)..where((t) => t.patientId.equals(patientId))).write(const OdontogramLocalCompanion(isSynced: Value(true)));
  }

  Odontogram _mapLocalToOdontogram(OdontogramLocalData local) => Odontogram.fromJson(jsonDecode(local.dataJson));
}
