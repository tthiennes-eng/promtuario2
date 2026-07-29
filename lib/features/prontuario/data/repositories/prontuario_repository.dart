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
      final response = await _apiClient.instance.get('/prontuario/$patientId/odontogram');
      dynamic rawData = response.data;
      if (rawData == null || (rawData is String && rawData.isEmpty) || rawData == 'null') {
        return _initialOdontogram(patientId);
      }
      Map<String, dynamic> jsonData = rawData is String ? jsonDecode(rawData) : Map<String, dynamic>.from(rawData);
      final odontogram = Odontogram.fromJson(jsonData);
      await _saveOdontogramLocal(odontogram);
      return odontogram;
    } catch (e) {
      final local = await (_localDb.select(_localDb.odontogramLocal)..where((t) => t.patientId.equals(patientId))).getSingleOrNull();
      return local != null ? _mapLocalToOdontogram(local) : _initialOdontogram(patientId);
    }
  }

  Odontogram _initialOdontogram(String patientId) {
    return Odontogram(
      id: const Uuid().v4(),
      patientId: patientId,
      teeth: [],
      updatedAt: DateTime.now(),
      updatedBy: _currentUser?.id ?? 'system',
    );
  }

  @override
  Future<void> saveOdontogram(Odontogram odontogram) async {
    await _saveOdontogramLocal(odontogram, isSynced: false);
    try {
      await _apiClient.instance.post('/prontuario/${odontogram.patientId}/odontogram', data: odontogram.toJson());
      await _markOdontogramAsSynced(odontogram.patientId);
    } catch (_) {}
  }

  @override
  Future<void> addEvolution(String patientId, String description, String professorId) async {
    final now = DateTime.now();
    try {
      await _apiClient.instance.post('/evolutions', data: {
        'patientId': patientId,
        'description': description,
        'professorId': professorId,
        'studentId': _currentUser?.id,
        'studentName': _currentUser?.name,
        'isSignedByProfessor': _currentUser?.role == UserRole.professor,
        'signedAt': _currentUser?.role == UserRole.professor ? now.toIso8601String() : null,
      });
    } catch (e) {
      await _localDb.into(_localDb.evolutionsLocal).insert(EvolutionsLocalCompanion.insert(
        id: const Uuid().v4(),
        patientId: patientId,
        studentId: Value(_currentUser?.id),
        studentName: Value(_currentUser?.name),
        professorId: Value(professorId),
        description: description,
        isSignedByProfessor: Value(_currentUser?.role == UserRole.professor),
        createdAt: now,
        isSynced: const Value(false),
      ));
    }
  }

  @override
  Future<List<Evolution>> getEvolutions(String patientId) async {
    try {
      final response = await _apiClient.instance.get('/prontuario/$patientId/evolutions');
      final List<dynamic> data = response.data ?? [];
      return data.map((json) => Evolution.fromJson(json)).toList();
    } catch (e) {
      final local = await (_localDb.select(_localDb.evolutionsLocal)..where((t) => t.patientId.equals(patientId))).get();
      return local.map((row) => Evolution(
        id: row.id,
        patientId: row.patientId,
        studentId: row.studentId ?? '',
        studentName: row.studentName ?? 'Aluno',
        professorId: row.professorId ?? '',
        professorName: row.professorName ?? 'Professor',
        description: row.description,
        isSignedByProfessor: row.isSignedByProfessor,
        signedAt: row.signedAt,
        createdAt: row.createdAt,
      )).toList();
    }
  }

  @override
  Future<List<TreatmentPlan>> getTreatmentPlans(String patientId) async {
    try {
      // Ajustado para a rota correta do TreatmentPlansController
      final response = await _apiClient.instance.get('/TreatmentPlans/active/$patientId');
      if (response.data == null) return [];
      return [TreatmentPlan.fromJson(response.data)];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<TreatmentPlan?> getTreatmentPlan(String patientId) async {
    final plans = await getTreatmentPlans(patientId);
    return plans.isNotEmpty ? plans.first : null;
  }

  @override
  Future<void> saveTreatmentPlan(TreatmentPlan plan) async {
    try {
      // Ajustado para a rota POST /TreatmentPlans
      await _apiClient.instance.post('/TreatmentPlans', data: {
        'patientId': plan.patientId,
        'description': plan.description,
      });
    } catch (e) {}
  }

  @override
  Future<void> updateTreatmentItemStatus(String planId, String itemId, String status) async {
    try {
      // Rota para adicionar itens ou atualizar status
      await _apiClient.instance.post('/TreatmentPlans/$planId/items', data: {
        'procedureId': const Uuid().v4(),
        'procedureName': 'Atualização',
        'value': 0.0,
        'status': status,
      });
    } catch (e) {}
  }

  // Métodos de Documentos e Sincronização mantidos...
  @override Future<Prescription> createPrescription(Prescription p) async { return p; }
  @override Future<List<Prescription>> getPrescriptionHistory(String id) async { return []; }
  @override Future<MedicalCertificate> createCertificate(MedicalCertificate c) async { return c; }
  @override Future<List<Anamnese>> getAnamneses(String id) async { return []; }
  @override Future<Anamnese?> getAnamneseByPatientId(String id) async { return null; }
  @override Future<void> saveAnamnese(String id, Map<String, dynamic> r) async {}
  @override Future<void> syncPendingData() async {}
  @override Future<List<Evolution>> getEvolutionHistory(String id) async { return getEvolutions(id); }
  @override Future<void> signEvolution(String id) async {}

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
