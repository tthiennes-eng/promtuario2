import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment.freezed.dart';
part 'attachment.g.dart';

enum AttachmentType {
  image,
  document,
  radiography,
  other;

  String get label {
    switch (this) {
      case AttachmentType.image:
        return 'Imagem';
      case AttachmentType.document:
        return 'Documento';
      case AttachmentType.radiography:
        return 'Radiografia';
      case AttachmentType.other:
        return 'Outro';
    }
  }
}

@freezed
class Attachment with _$Attachment {
  const factory Attachment({
    required String id,
    required String patientId,
    required String localPath,
    String? remoteUrl,
    required String type,
    String? description,
    required DateTime createdAt,
    @Default(false) bool isSynced,
  }) = _Attachment;

  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);
}
