import 'dart:convert';

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

  static Map<String, dynamic> _parseResponses(Map<String, dynamic> json) {
    final direct = json['responses'] ?? json['Responses'];
    if (direct is Map) {
      return Map<String, dynamic>.from(direct);
    }
    final rawJson = json['respostasJson'] ?? json['RespostasJson'];
    if (rawJson is String && rawJson.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    } else if (rawJson is Map) {
      return Map<String, dynamic>.from(rawJson);
    }
    // Se o próprio objeto JSON já for um mapa de respostas puro (cache local antigo)
    if (!json.containsKey('id') && !json.containsKey('Id') && !json.containsKey('patientId') && json.isNotEmpty) {
      return Map<String, dynamic>.from(json);
    }
    return {};
  }

  factory Anamnese.fromJson(Map<String, dynamic> json) {
    return Anamnese(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      patientId: (json['patientId'] ?? json['PatientId'])?.toString() ?? '',
      responses: _parseResponses(json),
      updatedAt: _safeParse(json['updatedAt'] ?? json['UpdatedAt'] ?? json['createdAt'] ?? json['CreatedAt']),
      updatedBy: (json['updatedBy'] ?? json['UpdatedBy'] ?? json['criadoPorId'] ?? json['CriadoPorId'] ?? '').toString(),
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
