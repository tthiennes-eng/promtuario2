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

  factory Anamnese.fromJson(Map<String, dynamic> json) {
    return Anamnese(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      responses: Map<String, dynamic>.from(json['responses'] as Map? ?? {}),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      updatedBy: json['updatedBy'] as String? ?? '',
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
