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

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'localPath': localPath,
        'remoteUrl': remoteUrl,
        'type': type,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'isSynced': isSynced,
      };

  Attachment copyWith({
    String? id,
    String? patientId,
    String? localPath,
    String? remoteUrl,
    String? type,
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
}
