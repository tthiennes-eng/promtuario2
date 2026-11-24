class Anamnese {
  final String id;
  final String patientId;
  final Map<String, dynamic> responses;
  final DateTime updatedAt;
  final String updatedBy;

  const Anamnese({
    required this.id,
    required this.patientId,
    required this.responses,
    required this.updatedAt,
    required this.updatedBy,
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

  factory Anamnese.fromJson(Map<String, dynamic> json) {
    return Anamnese(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      patientId: (json['patientId'] ?? json['PatientId'])?.toString() ?? '',
      responses: Map<String, dynamic>.from(json['responses'] as Map? ?? json['Responses'] as Map? ?? {}),
      updatedAt: _safeParse(json['updatedAt'] ?? json['UpdatedAt']),
      updatedBy: (json['updatedBy'] ?? json['UpdatedBy'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'responses': responses,
        'updatedAt': updatedAt.toIso8601String(),
        'updatedBy': updatedBy,
      };

  Anamnese copyWith({
    String? id,
    String? patientId,
    Map<String, dynamic>? responses,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return Anamnese(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      responses: responses ?? this.responses,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
