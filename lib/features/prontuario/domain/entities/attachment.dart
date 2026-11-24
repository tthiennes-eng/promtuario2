import 'package:promt/core/utils/date_utils.dart';

enum AttachmentType { image, video, document, xRay, other }

class Attachment {
  final String id;
  final String patientId;
  final String? localPath;
  final String? remoteUrl;
  final AttachmentType type;
  final String? description;
  final DateTime createdAt;
  final bool isSynced;

  const Attachment({
    required this.id,
    required this.patientId,
    this.localPath,
    this.remoteUrl,
    required this.type,
    this.description,
    required this.createdAt,
    this.isSynced = false,
  });

  // Getters para compatibilidade com ExamsScreen
  String get url => remoteUrl ?? localPath ?? '';
  String get name => description ?? 'Anexo';
  DateTime get date => createdAt;

  Attachment copyWith({
    String? id,
    String? patientId,
    String? localPath,
    String? remoteUrl,
    AttachmentType? type,
    String? description,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return Attachment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      type: type ?? this.type,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  factory Attachment.fromJson(Map<String, dynamic> json) {
    AttachmentType parseType(dynamic v) {
      if (v == null) return AttachmentType.image;
      final str = v.toString().toLowerCase();
      if (str.contains('image')) return AttachmentType.image;
      if (str.contains('video')) return AttachmentType.video;
      if (str.contains('doc')) return AttachmentType.document;
      if (str.contains('xray') || str.contains('raio')) return AttachmentType.xRay;
      return AttachmentType.values.firstWhere(
        (e) => e.name.toLowerCase() == str,
        orElse: () => AttachmentType.other,
      );
    }

    return Attachment(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      patientId: (json['patientId'] ?? json['PatientId'] ?? json['patient_id'] ?? '').toString(),
      localPath: json['localPath'] as String?,
      remoteUrl: (json['remoteUrl'] ?? json['Url'] ?? json['path']) as String?,
      type: parseType(json['type'] ?? json['Type']),
      description: (json['description'] ?? json['Description']) as String?,
      createdAt: SafeDateParser.parse(json['createdAt'] ?? json['CreatedAt']),
      isSynced: (json['isSynced'] ?? json['IsSynced'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'localPath': localPath,
    'remoteUrl': remoteUrl,
    'type': type.name,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'isSynced': isSynced,
  };
}
