import '../../../../core/network/api_client.dart';
import '../../domain/entities/wait_list_entry.dart';
import '../../domain/repositories/i_wait_list_repository.dart';

/// Implementação do repositório de lista de espera.
/// Conecta o frontend aos serviços de fila de espera do backend.
class WaitListRepository implements IWaitListRepository {
  final ApiClient _apiClient;

  WaitListRepository(this._apiClient);

  @override
  Future<List<WaitListEntry>> getWaitListByClinic(String clinicId) async {
    final response = await _apiClient.instance.get('/waitlist/clinic/$clinicId');
    final List<dynamic> data = response.data;
    return data.map((json) => WaitListEntry.fromJson(json)).toList();
  }

  @override
  Future<void> addToWaitList(WaitListEntry entry) async {
    await _apiClient.instance.post('/waitlist', data: {
      'patientId': entry.patientId,
      'clinicId': entry.clinicId,
      'specialty': entry.specialty,
      'priority': entry.priority,
      'observation': entry.observation,
    });
  }

  @override
  Future<void> resolveEntry(String entryId) async {
    await _apiClient.instance.patch('/waitlist/$entryId/resolve');
  }
}
