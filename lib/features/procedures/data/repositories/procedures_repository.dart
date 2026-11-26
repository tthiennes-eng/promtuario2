import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart' as drift_db;
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/features/procedures/domain/entities/procedure.dart';
import 'package:promt/features/procedures/domain/repositories/i_procedures_repository.dart';

class ProceduresRepository implements IProceduresRepository {
  final ApiClient _apiClient;
  final drift_db.AppDatabase _localDb;

  ProceduresRepository(this._apiClient, this._localDb);

  @override
  Future<List<Clinic>> getClinics({bool onlyActive = true}) async {
    try {
      final response = await _apiClient.instance.get('/clinics');
      final rawData = response.data;
      final List<dynamic> data = rawData is List
          ? rawData
          : (rawData is Map
                ? (rawData['data'] is List
                      ? rawData['data'] as List<dynamic>
                      : rawData['value'] is List
                      ? rawData['value'] as List<dynamic>
                      : rawData['items'] is List
                      ? rawData['items'] as List<dynamic>
                      : const <dynamic>[])
                : const <dynamic>[]);
      final clinics = data
          .whereType<Map>()
          .map((json) => Clinic.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      for (var clinic in clinics) {
        await _localDb
            .into(_localDb.clinicsLocal)
            .insertOnConflictUpdate(
              drift_db.ClinicsLocalCompanion(
                id: Value(clinic.id),
                name: Value(clinic.name),
                description: Value(clinic.description),
                location: Value(clinic.location),
                capacity: Value(clinic.capacity),
                isActive: Value(clinic.isActive),
                startHour: Value(clinic.startHour),
                endHour: Value(clinic.endHour),
                slotDurationMinutes: Value(clinic.slotDurationMinutes),
                metadataJson: Value(
                  clinic.metadata != null ? jsonEncode(clinic.metadata) : null,
                ),
              ),
            );
      }
      return clinics;
    } catch (e) {
      final localClinics = await _localDb.select(_localDb.clinicsLocal).get();
      return localClinics
          .map(
            (row) => Clinic(
              id: row.id,
              name: row.name,
              description: row.description ?? '',
              location: row.location ?? '',
              capacity: row.capacity,
              isActive: row.isActive,
              startHour: row.startHour,
              endHour: row.endHour,
              slotDurationMinutes: row.slotDurationMinutes,
            ),
          )
          .toList();
    }
  }

  @override
  Future<void> saveClinic(Clinic clinic) async {
    await _apiClient.instance.post('/clinics', data: clinic.toJson());
  }

  @override
  Future<void> syncClinics() async {
    await getClinics();
  }

  @override
  Future<List<Procedure>> getProceduresByClinic(String clinicId) async {
    try {
      final response = await _apiClient.instance.get(
        '/procedures/clinic/$clinicId',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Procedure.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Procedure>> getAllProcedures() async {
    try {
      final response = await _apiClient.instance.get('/procedures');
      final List<dynamic> data = response.data;
      return data.map((json) => Procedure.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }
}
