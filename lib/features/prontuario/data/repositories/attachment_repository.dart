import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/features/prontuario/domain/entities/attachment.dart';
import 'package:promt/features/prontuario/domain/repositories/i_attachment_repository.dart';
import 'package:uuid/uuid.dart';

class AttachmentRepository implements IAttachmentRepository {
  final ApiClient _apiClient;
  final AppDatabase _localDb;
  final _logger = Logger('AttachmentRepository');

  AttachmentRepository(this._apiClient, this._localDb);

  String _resolveAuthenticatedFileUrl(String id, String? rawUrl) {
    final base = _apiClient.instance.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (id.isNotEmpty) {
      return '$base/Anexos/$id/file';
    }
    return _resolveRemoteUrl(rawUrl);
  }

  String _resolveRemoteUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = _apiClient.instance.options.baseUrl;
    final uri = Uri.tryParse(base);
    if (uri == null) return trimmed;
    final origin = '${uri.scheme}://${uri.authority}';
    final normalizedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$origin$normalizedPath';
  }

  String _typeToApiLabel(AttachmentType type) {
    return switch (type) {
      AttachmentType.xRay => 'Radiografia',
      AttachmentType.image => 'Foto',
      AttachmentType.document => 'Documento',
      AttachmentType.video => 'Video',
      AttachmentType.other => 'Outro',
    };
  }

  AttachmentType _parseApiType(dynamic raw) {
    final s = (raw ?? '').toString().toLowerCase();
    if (s.contains('radio') || s.contains('xray') || s.contains('raio')) {
      return AttachmentType.xRay;
    }
    if (s.contains('foto') || s.contains('image')) return AttachmentType.image;
    if (s.contains('doc') || s.contains('laudo') || s.contains('pdf')) {
      return AttachmentType.document;
    }
    if (s.contains('video')) return AttachmentType.video;
    return AttachmentType.other;
  }

  @override
  Future<List<Attachment>> getAttachments(String patientId) async {
    final remoteAttachments = <Attachment>[];
    try {
      final response = await _apiClient.instance.get('Anexos/paciente/$patientId');
      if (response.data is List) {
        for (final item in response.data as List) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            final id = (map['id'] ?? map['Id'] ?? '').toString();
            final remoteUrl = _resolveAuthenticatedFileUrl(
              id,
              (map['url'] ?? map['Url'] ?? map['remoteUrl'])?.toString(),
            );
            final att = Attachment(
              id: id,
              patientId: patientId,
              remoteUrl: remoteUrl.isEmpty ? null : remoteUrl,
              type: _parseApiType(map['tipo'] ?? map['Tipo'] ?? map['type']),
              description: (map['nome'] ?? map['Nome'] ?? map['description'] ?? 'Exame').toString(),
              createdAt: DateTime.tryParse((map['createdAt'] ?? map['CreatedAt'] ?? '').toString())?.toLocal() ??
                  DateTime.now(),
              isSynced: true,
            );
            remoteAttachments.add(att);
          }
        }
      }
    } catch (e) {
      _logger.warning('Erro ao buscar anexos remotos: $e');
    }

    final localAttachments = <Attachment>[];
    try {
      final query = _localDb.select(_localDb.attachmentsLocal)
        ..where((t) => t.patientId.equals(patientId));
      final results = await query.get();
      for (final row in results) {
        final mapped = _mapSchemaToEntity(row);
        if (!remoteAttachments.any((r) => r.id == mapped.id)) {
          localAttachments.add(mapped);
        }
      }
    } catch (e) {
      _logger.warning('Erro ao ler anexos locais: $e');
    }

    final merged = [...remoteAttachments, ...localAttachments];
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  @override
  Future<Attachment> uploadAttachment(
    String patientId,
    File file,
    AttachmentType type, {
    String? description,
  }) async {
    final fileName = (description != null && description.trim().isNotEmpty)
        ? description.trim()
        : p.basename(file.path);

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: p.basename(file.path)),
      });
      final response = await _apiClient.instance.post(
        'Anexos/upload/$patientId',
        queryParameters: {'tipo': _typeToApiLabel(type)},
        data: formData,
      );
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        final id = (map['id'] ?? map['Id'] ?? const Uuid().v4()).toString();
        final remoteUrl = _resolveAuthenticatedFileUrl(id, (map['url'] ?? map['Url'])?.toString());
        final uploaded = Attachment(
          id: id,
          patientId: patientId,
          localPath: file.path,
          remoteUrl: remoteUrl.isEmpty ? null : remoteUrl,
          type: type,
          description: (map['nome'] ?? map['Nome'] ?? fileName).toString(),
          createdAt: DateTime.now(),
          isSynced: true,
        );
        await _saveLocal(uploaded);
        return uploaded;
      }
    } catch (e) {
      _logger.warning('Upload remoto de anexo falhou, salvando localmente: $e');
    }

    final attachment = Attachment(
      id: const Uuid().v4(),
      patientId: patientId,
      localPath: file.path,
      type: type,
      description: fileName,
      createdAt: DateTime.now(),
      isSynced: false,
    );
    await _saveLocal(attachment);
    return attachment;
  }

  Future<Attachment?> _tryUploadRemote(
    String patientId,
    File file,
    AttachmentType type,
    String fileName,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    final response = await _apiClient.instance.post(
      'Anexos/upload/$patientId',
      queryParameters: {'tipo': _typeToApiLabel(type)},
      data: formData,
    );
    if (response.data is Map) {
      final map = Map<String, dynamic>.from(response.data as Map);
      final remoteId = (map['id'] ?? map['Id'] ?? const Uuid().v4()).toString();
      final remoteUrl = _resolveAuthenticatedFileUrl(remoteId, (map['url'] ?? map['Url'])?.toString());
      return Attachment(
        id: remoteId,
        patientId: patientId,
        localPath: file.path,
        remoteUrl: remoteUrl.isEmpty ? null : remoteUrl,
        type: type,
        description: (map['nome'] ?? map['Nome'] ?? fileName).toString(),
        createdAt: DateTime.now(),
        isSynced: true,
      );
    }
    return null;
  }

  @override
  Future<void> deleteAttachment(String id) async {
    try {
      await _apiClient.instance.delete('Anexos/$id');
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode != 404) {
        final data = e.response?.data;
        final msg = data is Map ? (data['message'] ?? data['title'])?.toString() : data?.toString();
        throw Exception(msg ?? 'Sem permissão ou erro ao excluir anexo (HTTP ${e.response?.statusCode}).');
      }
      _logger.warning('Erro de rede ao excluir anexo no servidor ($id): $e');
    }
    try {
      await (_localDb.delete(_localDb.attachmentsLocal)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      _logger.warning('Erro ao excluir anexo local ($id): $e');
    }
  }

  @override
  Future<bool> syncPendingAttachment(String id) async {
    try {
      final row = await (_localDb.select(_localDb.attachmentsLocal)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      final localPath = row?.localPath;
      if (row == null || row.isSynced || localPath == null || localPath.isEmpty) return true;
      final file = File(localPath);
      if (!file.existsSync()) return false;
      final type = AttachmentType.values.firstWhere(
        (e) => e.name == row.type,
        orElse: () => AttachmentType.other,
      );
      final fileName = (row.description != null && row.description!.trim().isNotEmpty)
          ? row.description!.trim()
          : p.basename(file.path);
      final uploaded = await _tryUploadRemote(row.patientId, file, type, fileName);
      if (uploaded != null && uploaded.isSynced) {
        await _saveLocal(uploaded);
        if (uploaded.id != id) {
          await (_localDb.delete(_localDb.attachmentsLocal)..where((t) => t.id.equals(id))).go();
        }
        return true;
      }
      return false;
    } catch (e) {
      _logger.warning('Erro ao sincronizar anexo pendente ($id): $e');
      return false;
    }
  }

  Future<void> _saveLocal(Attachment attachment) async {
    try {
      await _localDb.into(_localDb.attachmentsLocal).insertOnConflictUpdate(
        AttachmentsLocalCompanion(
          id: Value(attachment.id),
          patientId: Value(attachment.patientId),
          localPath: Value(attachment.localPath ?? attachment.remoteUrl ?? ''),
          type: Value(attachment.type.name),
          description: Value(attachment.description ?? ''),
          createdAt: Value(attachment.createdAt),
          isSynced: Value(attachment.isSynced),
        ),
      );
    } catch (e) {
      _logger.warning('Erro ao salvar anexo no cache local (${attachment.id}): $e');
    }
  }

  Attachment _mapSchemaToEntity(dynamic row) {
    final storedPath = row.localPath as String?;
    final isHttp = storedPath != null &&
        (storedPath.startsWith('http://') || storedPath.startsWith('https://'));
    return Attachment(
      id: row.id as String,
      patientId: row.patientId as String,
      localPath: isHttp ? null : storedPath,
      remoteUrl: isHttp ? storedPath : null,
      type: AttachmentType.values.firstWhere(
        (e) => e.name == row.type,
        orElse: () => AttachmentType.other,
      ),
      description: row.description as String?,
      createdAt: row.createdAt as DateTime,
      isSynced: row.isSynced as bool,
    );
  }
}
