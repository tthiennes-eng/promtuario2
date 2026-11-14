import 'package:drift/drift.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/features/procedures/domain/entities/procedure.dart';
import 'package:promt/features/procedures/domain/repositories/i_procedures_repository.dart';

class ProceduresRepository implements IProceduresRepository {
  final ApiClient _apiClient;
  final AppDatabase _localDb;

  ProceduresRepository(this._apiClient, this._localDb);

  @override
  Future<List<Clinic>> getClinics({bool onlyActive = true}) async {
    try {
      final response = await _apiClient.instance.get('/clinics');
      final List<dynamic> data = response.data;
      final clinics = data.map((json) => Clinic.fromJson(json)).toList();
      
      final dynamic db = _localDb;
      for (var clinic in clinics) {
        await db.into(db.clinicsLocal).insertOnConflictUpdate(
          drift_db.ClinicsLocalCompanion.insert(
            id: clinic.id,
            name: clinic.name,
            description: Value(clinic.description),
            location: Value(clinic.location),
            capacity: Value(clinic.capacity),
            isActive: Value(clinic.isActive),
          ),
        );
      }
      return clinics;
    } catch (e) {
      final dynamic db = _localDb;
      final localClinics = await db.select(db.clinicsLocal).get();
      return (localClinics as List).map((row) => Clinic(
        id: row.id,
        name: row.name,
        description: row.description ?? '',
        location: row.location ?? '',
        capacity: row.capacity,
        isActive: row.isActive,
      )).toList();
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
      final response = await _apiClient.instance.get('/procedures/clinic/$clinicId');
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
