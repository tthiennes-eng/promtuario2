import 'package:freezed_annotation/freezed_annotation.dart';

// part 'attachment.freezed.dart';
// part 'attachment.g.dart';

@freezed
class Attachment {
  final String id;
  final String patientId;
  final String localPath;
  final String? remoteUrl;
  final String type;
  final String? description;
  final DateTime createdAt;
  final bool isSynced;

  const Attachment({
    required this.id,
    required this.patientId,
    required this.localPath,
    this.remoteUrl,
    required this.type,
    this.description,
    required this.createdAt,
    this.isSynced = false,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      localPath: json['localPath'] as String? ?? '',
      remoteUrl: json['remoteUrl'] as String?,
      type: json['type'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }
}
