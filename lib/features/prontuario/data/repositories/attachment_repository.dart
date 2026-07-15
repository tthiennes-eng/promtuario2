import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/repositories/i_attachment_repository.dart';

/// Implementação do repositório de anexos.
/// Gerencia o envio de arquivos binários para o servidor.
class AttachmentRepository implements IAttachmentRepository {
  final ApiClient _apiClient;

  AttachmentRepository(this._apiClient);

  @override
  Future<Attachment> uploadAttachment(
    String patientId,
    File file,
    AttachmentType type, {
    String? description,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      'tipo': type.name,
      if (description != null) 'description': description,
    });

    final response = await _apiClient.instance.post(
      '/anexos/upload/$patientId',
      data: formData,
    );

    return _mapJsonToEntity(response.data);
  }

  @override
  Future<List<Attachment>> getAttachments(String patientId) async {
    final response = await _apiClient.instance.get('/anexos/paciente/$patientId');
    final List<dynamic> data = response.data;
    return data.map((json) => _mapJsonToEntity(json)).toList();
  }

  @override
  Future<void> deleteAttachment(String attachmentId) async {
    await _apiClient.instance.delete('/anexos/$attachmentId');
  }

  Attachment _mapJsonToEntity(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      patientId: json['pacienteId'],
      name: json['nome'],
      type: AttachmentType.values.firstWhere(
        (e) => e.name == json['tipo'].toString().toLowerCase(),
        orElse: () => AttachmentType.document,
      ),
      url: json['url'],
      date: DateTime.parse(json['criadoEm'] ?? json['data'] ?? DateTime.now().toIso8601String()),
      uploadedBy: json['criadoPorId'],
      description: json['descricao'],
    );
  }
}
