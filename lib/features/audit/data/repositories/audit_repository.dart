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
    try {
      await _localDb.into(_localDb.auditLocal).insert(
        AuditLocalCompanion(
          resourceId: Value(resourceId),
          action: Value(action),
          timestamp: Value(DateTime.now()),
          isSynced: const Value(false),
        ),
      );
    } catch (_) {}

    try {
      await _apiClient.instance.post('Logs/access', data: {
        'resourceId': resourceId,
        'action': action,
      });
    } catch (_) {}
  }

  List<AuditLog> _parseLogsPayload(dynamic raw) {
    final List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map) {
      final items = raw['items'] ?? raw['Items'];
      list = items is List ? items : const [];
    } else {
      list = const [];
    }
    return list
        .whereType<Map>()
        .map((json) => AuditLog.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<List<AuditLog>> getLogs({String? userId, String? action}) async {
    final response = await _apiClient.instance.get('Logs', queryParameters: {
      if (userId != null) 'userId': userId,
      if (action != null) 'action': action,
    });
    return _parseLogsPayload(response.data);
  }

  Future<List<AuditLog>> getAuditLogs({String? resourceId, String? userId}) async {
    final response = await _apiClient.instance.get('Logs', queryParameters: {
      if (resourceId != null) 'resourceId': resourceId,
      if (userId != null) 'userId': userId,
    });
    return _parseLogsPayload(response.data);
  }

  @override
  Future<bool> syncPendingAccess(String resourceId, String action) async {
    try {
      final response = await _apiClient.instance.post('Logs/access', data: {
        'resourceId': resourceId,
        'action': action,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
