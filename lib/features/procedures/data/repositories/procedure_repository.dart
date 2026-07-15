import '../../../../core/network/api_client.dart';
import '../../domain/entities/procedure.dart';
import '../../domain/repositories/i_procedure_repository.dart';

/// Implementação do repositório de procedimentos.
/// Busca no catálogo do backend os serviços oferecidos pela clínica.
class ProcedureRepository implements IProcedureRepository {
  final ApiClient _apiClient;

  ProcedureRepository(this._apiClient);

  @override
  Future<List<Procedure>> getProcedures() async {
    final response = await _apiClient.instance.get('/procedures');
    final List<dynamic> data = response.data;
    return data.map((json) => Procedure.fromJson(json)).toList();
  }

  @override
  Future<List<Procedure>> getProceduresBySpecialty(String specialty) async {
    final response = await _apiClient.instance.get('/procedures/specialty/$specialty');
    final List<dynamic> data = response.data;
    return data.map((json) => Procedure.fromJson(json)).toList();
  }
}
