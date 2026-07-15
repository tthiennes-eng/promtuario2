import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment.freezed.dart';

@freezed
class Attachment with _$Attachment {
  const factory Attachment({
    required String id,
    required String patientId,
    required String name,
    required AttachmentType type,
    required String url,
    required DateTime date,
    required String uploadedBy,
    String? description,
  }) = _Attachment;
}

enum AttachmentType {
  radiography,
  photo,
  document,
  exam,
}
