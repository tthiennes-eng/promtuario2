import '../../../../core/network/api_client.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/repositories/i_audit_repository.dart';

/// Implementação do repositório de auditoria.
/// Recupera registros de acesso e modificações para conformidade LGPD.
class AuditRepository implements IAuditRepository {
  final ApiClient _apiClient;

  AuditRepository(this._apiClient);

  @override
  Future<List<AuditLog>> getLogs({int page = 1, int pageSize = 50, String? userId}) async {
    final response = await _apiClient.instance.get('/logs', queryParameters: {
      'page': page,
      'pageSize': pageSize,
      if (userId != null) 'userId': userId,
    });

    final List<dynamic> data = response.data['items'];
    return data.map((json) => AuditLog.fromJson(json)).toList();
  }
}
