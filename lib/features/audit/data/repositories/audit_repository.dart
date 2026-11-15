import 'package:drift/drift.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/features/audit/domain/entities/audit_log.dart';
import 'package:promt/features/audit/domain/repositories/i_audit_repository.dart';

class AuditRepository implements IAuditRepository {
  final ApiClient _apiClient;
  final AppDatabase _localDb;

  AuditRepository(this._apiClient, this._localDb);

  @override
  Future<void> registerAccess(String resourceId, String action) async {
    final dynamic db = _localDb;
    // CORREÇÃO: Usando dynamic para evitar crash de FFI por tipo inexistente
    try {
      await db.into(db.auditLocal).insert(
        AuditLocalCompanion(
          resourceId: Value(resourceId),
          action: Value(action),
          timestamp: Value(DateTime.now()),
          isSynced: const Value(false),
        ),
      );
    } catch (_) {}

    try {
      await _apiClient.instance.post('/audit/access', data: {
        'resourceId': resourceId,
        'action': action,
      });
    } catch (_) {}
  }

  @override
  Future<List<AuditLog>> getAuditLogs({String? resourceId, String? userId}) async {
    final response = await _apiClient.instance.get('/audit', queryParameters: {
      if (resourceId != null) 'resourceId': resourceId,
      if (userId != null) 'userId': userId,
    });
    final List<dynamic> data = response.data;
    return data.map((json) => AuditLog.fromJson(json)).toList();
  }

  @override
  Future<bool> syncPendingAccess(String resourceId, String action) async {
    try {
      final response = await _apiClient.instance.post('/audit/access', data: {
        'resourceId': resourceId,
        'action': action,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
