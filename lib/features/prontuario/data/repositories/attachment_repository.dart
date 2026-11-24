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

  @override
  Future<List<Attachment>> getAttachments(String patientId) async {
    try {
      final query = _localDb.select(_localDb.attachmentsLocal)
        ..where((t) => t.patientId.equals(patientId));
      final results = await query.get();
      return results.map((row) => _mapSchemaToEntity(row)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Attachment> uploadAttachment(
    String patientId,
    File file,
    AttachmentType type, {
    String? description,
  }) async {
    final attachment = Attachment(
      id: const Uuid().v4(),
      patientId: patientId,
      localPath: file.path,
      type: type,
      description: description,
      createdAt: DateTime.now(),
      isSynced: false,
    );
    await _saveLocal(attachment);
    return attachment;
  }

  @override
  Future<void> deleteAttachment(String id) async {
    try {
      await (_localDb.delete(_localDb.attachmentsLocal)..where((t) => t.id.equals(id))).go();
    } catch (_) {}
  }

  @override
  Future<bool> syncPendingAttachment(String id) async {
    return true; 
  }

  Future<void> _saveLocal(Attachment attachment) async {
    try {
      await _localDb.into(_localDb.attachmentsLocal).insertOnConflictUpdate(
        AttachmentsLocalCompanion(
          id: Value(attachment.id),
          patientId: Value(attachment.patientId),
          localPath: Value(attachment.localPath),
          type: Value(attachment.type.name),
          description: Value(attachment.description),
          createdAt: Value(attachment.createdAt),
          isSynced: Value(attachment.isSynced),
        ),
      );
    } catch (_) {}
  }

  Attachment _mapSchemaToEntity(dynamic row) {
    // row é do tipo AttachmentLocalData gerado pelo Drift
    // Usamos o método toJson do Drift que já lida com a conversão de campos
    final data = row.toJson();
    return Attachment.fromJson(data);
  }
}
