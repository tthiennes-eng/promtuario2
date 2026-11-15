import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment.freezed.dart';
part 'attachment.g.dart';

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
