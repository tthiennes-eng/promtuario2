import 'dart:io';
import 'package:drift/drift.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/features/prontuario/domain/entities/attachment.dart';
import 'package:promt/features/prontuario/domain/repositories/i_attachment_repository.dart';
import 'package:uuid/uuid.dart';

class AttachmentRepository implements IAttachmentRepository {
  final ApiClient _apiClient;
  final AppDatabase _localDb;

  AttachmentRepository(this._apiClient, this._localDb);

  static DateTime _safeParse(dynamic v) {
    if (v == null || v.toString().trim().isEmpty || v.toString() == 'null') {
      return DateTime.now();
    }
    try {
      if (v is DateTime) return v.isUtc ? v.toLocal() : v;
      final s = v.toString();
      final dateStr = s.contains('T') || s.contains(' ') ? s : '${s}T00:00:00';
      final dt = DateTime.parse(dateStr);
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  Future<List<Attachment>> getAttachments(String patientId) async {
    final dynamic db = _localDb;
    try {
      final query = db.select(db.attachmentsLocal)
        ..where((t) => t.patientId.equals(patientId));
      final results = await query.get();
      return (results as List).map((row) => _mapSchemaToEntity(row)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Attachment> uploadAttachment(
    String patientId,
    File file,
    String type, {
    String? description,
  }) async {
    final attachment = Attachment(
      id: const Uuid().v4(),
      patientId: patientId,
      localPath: file.path,
      type: type,
      description: description,
      createdAt: DateTime.now(),
    );
    await _saveLocal(attachment);
    return attachment;
  }

  @override
  Future<void> deleteAttachment(String id) async {
    final dynamic db = _localDb;
    try {
      await (db.delete(db.attachmentsLocal)..where((t) => t.id.equals(id))).go();
    } catch (_) {}
  }

  @override
  Future<bool> syncPendingAttachment(String id) async {
    return true; 
  }

  Future<void> _saveLocal(Attachment attachment) async {
    final dynamic db = _localDb;
    try {
      await db.into(db.attachmentsLocal).insertOnConflictUpdate(
        AttachmentsLocalCompanion(
          id: Value(attachment.id),
          patientId: Value(attachment.patientId),
          localPath: Value(attachment.localPath),
          type: Value(attachment.type),
          description: Value(attachment.description),
          createdAt: Value(attachment.createdAt),
          isSynced: Value(attachment.isSynced),
        ),
      );
    } catch (_) {}
  }

  Attachment _mapSchemaToEntity(dynamic row) {
    final data = row.toJson();
    return Attachment(
      id: (data['id'] ?? '') as String,
      patientId: (data['patientId'] ?? '') as String,
      localPath: data['localPath'] as String?,
      remoteUrl: data['remoteUrl'] as String?,
      type: (data['type'] ?? 'file') as String,
      description: data['description'] as String?,
      createdAt: _safeParse(data['createdAt']),
      isSynced: data['isSynced'] as bool? ?? false,
    );
  }
}
