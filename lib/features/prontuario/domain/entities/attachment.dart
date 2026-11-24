class Attachment {
  final String id;
  final String patientId;
  final String? localPath;
  final String? remoteUrl;
  final String type;
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

  static DateTime _safeParse(dynamic v) {
    if (v == null || v.toString().trim().isEmpty || v.toString() == 'null') {
      return DateTime.now();
    }
    try {
      if (v is DateTime) return v.isUtc ? v.toLocal() : v;
      final s = v.toString();
      final dateStr = s.contains('T') || s.contains(' ') ? s : '${s}T00:00:00';
      final dt = DateTime.parse(dateStr);
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (_) {
      return DateTime.now();
    }
  }

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      patientId: (json['patientId'] ?? json['PatientId'])?.toString() ?? '',
      localPath: json['localPath'] as String?,
      remoteUrl: (json['remoteUrl'] ?? json['Url'] ?? json['path']) as String?,
      type: (json['type'] ?? json['Type'] ?? 'file') as String,
      description: (json['description'] ?? json['Description']) as String?,
      createdAt: _safeParse(json['createdAt'] ?? json['CreatedAt']),
      isSynced: (json['isSynced'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'type': type,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'remoteUrl': remoteUrl,
      };
}
