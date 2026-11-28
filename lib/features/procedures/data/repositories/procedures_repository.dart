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
      final clinics = Clinic.sortBySequence(
        data
            .whereType<Map>()
            .map((json) => Clinic.fromJson(Map<String, dynamic>.from(json))),
      );

      final remoteIds = clinics.map((c) => c.id).toSet();
      final existingLocal = await _localDb.select(_localDb.clinicsLocal).get();
      for (final row in existingLocal) {
        if (!remoteIds.contains(row.id)) {
          await (_localDb.delete(_localDb.clinicsLocal)
                ..where((t) => t.id.equals(row.id)))
              .go();
        }
      }

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
      return onlyActive ? clinics.where((c) => c.isActive).toList() : clinics;
    } catch (e) {
      final localClinics = await _localDb.select(_localDb.clinicsLocal).get();
      final mapped = Clinic.sortBySequence(
        localClinics.map(
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
        ),
      );
      return onlyActive ? mapped.where((c) => c.isActive).toList() : mapped;
    }
  }

  @override
  Future<void> saveClinic(Clinic clinic) async {
    final trimmedId = clinic.id.trim();
    if (trimmedId.isNotEmpty) {
      await _apiClient.instance.put('/clinics/$trimmedId', data: clinic.toJson());
    } else {
      final payload = Map<String, dynamic>.from(clinic.toJson())..remove('id');
      await _apiClient.instance.post('/clinics', data: payload);
    }
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
