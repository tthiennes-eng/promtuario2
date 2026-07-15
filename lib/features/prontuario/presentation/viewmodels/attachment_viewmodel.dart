import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/repositories/i_attachment_repository.dart';
import '../../../../core/providers/providers.dart';

part 'attachment_viewmodel.g.dart';

@riverpod
class AttachmentViewModel extends _$AttachmentViewModel {
  @override
  FutureOr<List<Attachment>> build(String patientId) async {
    return _fetchAttachments(patientId);
  }

  Future<List<Attachment>> _fetchAttachments(String patientId) async {
    final repository = ref.read(attachmentRepositoryProvider);
    return await repository.getAttachments(patientId);
  }

  Future<void> uploadFile(File file, AttachmentType type, {String? description}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(attachmentRepositoryProvider);
      await repository.uploadAttachment(arg, file, type, description: description);
      return _fetchAttachments(arg);
    });
  }

  Future<void> removeAttachment(String attachmentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(attachmentRepositoryProvider);
      await repository.deleteAttachment(attachmentId);
      return _fetchAttachments(arg);
    });
  }
}
