import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/features/agenda/domain/entities/wait_list_entry.dart';
import 'package:promt/features/agenda/domain/repositories/i_wait_list_repository.dart';

class WaitListRepository implements IWaitListRepository {
  final ApiClient _apiClient;
  final AppDatabase _localDb;

  WaitListRepository(this._apiClient, this._localDb);

  @override
  Future<List<WaitListEntry>> getWaitListByClinic(String clinicId) async {
    try {
      final response = await _apiClient.instance.get('WaitList/clinic/$clinicId');

      final List<dynamic> data = response.data is List ? response.data as List : const [];
      final entries = data
          .whereType<Map>()
          .map((json) => WaitListEntry.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      await _updateLocalCache(clinicId, entries);
      return entries;
    } catch (e) {
      final results = await (_localDb.select(_localDb.waitListLocal)
            ..where((t) => t.clinicId.equals(clinicId)))
          .get();

      return results.map((row) => WaitListEntry(
        id: row.id,
        patientId: row.patientId,
        patientName: row.patientName,
        clinicId: row.clinicId,
        specialty: row.specialty,
        priority: row.priority,
        observation: row.observation,
        createdAt: row.createdAt,
      )).toList();
    }
  }

  @override
  Future<void> addToWaitList(WaitListEntry entry) async {
    try {
      final response = await _apiClient.instance.post('WaitList', data: entry.toJson());
      var saved = entry;
      if (response.data is Map) {
        saved = WaitListEntry.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
      await _saveLocal(saved, true);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final msg = data is Map ? (data['message'] ?? data['title'])?.toString() : data?.toString();
        throw Exception(msg ?? 'Erro ao adicionar à lista de espera (HTTP ${e.response?.statusCode}).');
      }
      await _saveLocal(entry, false);
    }
  }

  @override
  Future<void> resolveEntry(String entryId) async {
    try {
      await _apiClient.instance.patch('WaitList/$entryId/resolve');
      await (_localDb.delete(_localDb.waitListLocal)..where((t) => t.id.equals(entryId))).go();
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final msg = data is Map ? (data['message'] ?? data['title'])?.toString() : data?.toString();
        throw Exception(msg ?? 'Erro ao atualizar lista de espera (HTTP ${e.response?.statusCode}).');
      }
      rethrow;
    }
  }

  @override
  Future<void> syncWaitList() async {
    final unsynced = await (_localDb.select(_localDb.waitListLocal)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    for (final row in unsynced) {
      try {
        final entry = WaitListEntry(
          id: row.id,
          patientId: row.patientId,
          patientName: row.patientName,
          clinicId: row.clinicId,
          priority: row.priority,
          specialty: row.specialty,
          observation: row.observation,
          createdAt: row.createdAt,
        );
        final response = await _apiClient.instance.post('WaitList', data: entry.toJson());
        if (response.data is Map) {
          final remote = WaitListEntry.fromJson(Map<String, dynamic>.from(response.data as Map));
          if (remote.id.isNotEmpty && remote.id != row.id) {
            await (_localDb.delete(_localDb.waitListLocal)..where((t) => t.id.equals(row.id))).go();
            await _saveLocal(remote, true);
            continue;
          }
        }
        await (_localDb.update(_localDb.waitListLocal)..where((t) => t.id.equals(row.id))).write(
          const WaitListLocalCompanion(isSynced: Value(true)),
        );
      } catch (_) {}
    }
  }

  Future<void> _saveLocal(WaitListEntry entry, bool isSynced) async {
    await _localDb.into(_localDb.waitListLocal).insertOnConflictUpdate(
      WaitListLocalCompanion.insert(
        id: entry.id,
        patientId: entry.patientId,
        patientName: entry.patientName,
        clinicId: entry.clinicId,
        priority: entry.priority,
        specialty: entry.specialty,
        observation: Value(entry.observation),
        createdAt: entry.createdAt,
        isSynced: Value(isSynced),
      ),
    );
  }

  Future<void> _updateLocalCache(String clinicId, List<WaitListEntry> entries) async {
    final remoteIds = entries.map((e) => e.id).toSet();
    final existingSynced = await (_localDb.select(_localDb.waitListLocal)
          ..where((t) => t.clinicId.equals(clinicId) & t.isSynced.equals(true)))
        .get();
    for (final row in existingSynced) {
      if (!remoteIds.contains(row.id)) {
        await (_localDb.delete(_localDb.waitListLocal)..where((t) => t.id.equals(row.id))).go();
      }
    }
    for (var entry in entries) {
      await _saveLocal(entry, true);
    }
  }
}
