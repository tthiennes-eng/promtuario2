import 'package:drift/drift.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/database/local_database.dart';
import '../../domain/entities/clinic.dart';
import '../../domain/entities/procedure.dart';
import '../../domain/repositories/i_procedures_repository.dart';

/// Implementação do repositório de Clínicas e Procedimentos.
/// Gerencia o cadastro e consulta de clínicas da instituição.
class ProceduresRepository implements IProceduresRepository {
  final ApiClient _apiClient;
  final AppDatabase _localDb;

  ProceduresRepository(this._apiClient, this._localDb);

  @override
  Future<List<Clinic>> getClinics({bool onlyActive = true}) async {
    try {
      // Tenta buscar da API primeiro para manter atualizado
      final response = await _apiClient.instance.get('/clinics');
      final List<dynamic> data = response.data ?? [];
      final clinics = data.map((json) => Clinic.fromJson(json)).toList();
      
      // Atualiza cache local
      for (final clinic in clinics) {
        await saveClinicLocal(clinic);
      }

      return onlyActive ? clinics.where((c) => c.isActive).toList() : clinics;
    } catch (e) {
      // Fallback para o banco local
      final query = _localDb.select(_localDb.clinicsLocal);
      if (onlyActive) {
        query.where((t) => t.isActive.equals(true));
      }
      final results = await query.get();
      return results.map((row) => Clinic(
        id: row.id,
        name: row.name,
        description: row.description,
        location: row.location,
        capacity: row.capacity,
        isActive: row.isActive,
      )).toList();
    }
  }

  @override
  Future<void> saveClinic(Clinic clinic) async {
    try {
      await _apiClient.instance.put(
        '/clinics/${clinic.id}',
        data: clinic.toJson(),
      );
      await saveClinicLocal(clinic);
    } catch (e) {
      // Em caso de falha na rede, salva localmente para posterior sincronia (se implementado)
      await saveClinicLocal(clinic);
    }
  }

  Future<void> saveClinicLocal(Clinic clinic) async {
    await _localDb.into(_localDb.clinicsLocal).insertOnConflictUpdate(
      ClinicsLocalCompanion.insert(
        id: clinic.id,
        name: clinic.name,
        description: Value(clinic.description),
        location: Value(clinic.location),
        capacity: Value(clinic.capacity),
        isActive: Value(clinic.isActive),
      ),
    );
  }

  @override
  Future<List<Procedure>> getProceduresByClinic(String clinicId) async {
    try {
      final response = await _apiClient.instance.get('/clinics/$clinicId/procedures');
      final List<dynamic> data = response.data ?? [];
      return data.map((json) => Procedure.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Procedure>> getAllProcedures() async {
    try {
      final response = await _apiClient.instance.get('/procedures');
      final List<dynamic> data = response.data ?? [];
      return data.map((json) => Procedure.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
