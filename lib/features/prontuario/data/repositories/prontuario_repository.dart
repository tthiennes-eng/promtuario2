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
import 'package:dio/dio.dart';

class ProntuarioRepository implements IProntuarioRepository {
  final ApiClient _apiClient;
  final AppDatabase _localDb;
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
    try {
      final response = await _apiClient.instance.get('Prontuario/$patientId/odontogram');
      if (response.data == null || response.data == 'null') return _initialOdontogram(patientId);
      return Odontogram.fromJson(response.data is String ? jsonDecode(response.data) : response.data);
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
    await _apiClient.instance.post('Prontuario/odontogram', data: odontogram.toJson());
  }

  @override
  Future<void> saveTreatmentPlan(TreatmentPlan plan) async {
    final clinicId = await _getDefaultClinicId();
    final data = plan.toJson();
    data['clinicId'] = clinicId;
    await _apiClient.instance.post('TreatmentPlans', data: data);
  }

  @override
  Future<Prescription> createPrescription(Prescription prescription) async {
    final clinicId = await _getDefaultClinicId();
    final data = prescription.toJson();
    data['clinicId'] = clinicId;
    final response = await _apiClient.instance.post('Documentos/receitas', data: data);
    return Prescription.fromJson(response.data);
  }

  @override
  Future<List<Prescription>> getPrescriptionHistory(String patientId) async {
    final response = await _apiClient.instance.get('Documentos/receitas/$patientId');
    return (response.data as List).map((json) => Prescription.fromJson(json)).toList();
  }

  @override
  Future<MedicalCertificate> createCertificate(MedicalCertificate certificate) async {
    final clinicId = await _getDefaultClinicId();
    final data = certificate.toJson();
    data['clinicId'] = clinicId;
    final response = await _apiClient.instance.post('Documentos/atestados', data: data);
    return MedicalCertificate.fromJson(response.data);
  }

  @override
  Future<List<MedicalCertificate>> getCertificateHistory(String patientId) async {
    final response = await _apiClient.instance.get('Documentos/atestados/$patientId');
    return (response.data as List).map((json) => MedicalCertificate.fromJson(json)).toList();
  }

  @override
  Future<List<TreatmentPlan>> getTreatmentPlans(String patientId) async {
    try {
      final response = await _apiClient.instance.get('TreatmentPlans/active/$patientId');
      return [TreatmentPlan.fromJson(response.data)];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
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
    return (response.data as List).map((json) => Evolution.fromJson(json)).toList();
  }

  @override
  Future<void> signEvolution(String evolutionId) async {
    await _apiClient.instance.post('Evolutions/$evolutionId/sign', data: {});
  }

  @override
  Future<List<Anamnese>> getAnamneses(String patientId) async {
    try {
      final response = await _apiClient.instance.get('Prontuario/$patientId/anamneses');
      final List<dynamic> data = response.data ?? [];
      return data.map((json) => Anamnese.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Anamnese?> getAnamneseByPatientId(String patientId) async {
    final results = await getAnamneses(patientId);
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<void> saveAnamnese(String patientId, Map<String, dynamic> responses) async {
    await _apiClient.instance.post('Prontuario/$patientId/anamnese', data: responses);
  }

  @override
  Future<void> syncPendingData() async {}
  @override
  Future<List<Evolution>> getEvolutionHistory(String patientId) async => getEvolutions(patientId);
  @override
  Future<TreatmentPlan?> getTreatmentPlan(String patientId) async => null;
  @override
  Future<void> updateTreatmentItemStatus(String planId, String itemId, String status) async {}
}
