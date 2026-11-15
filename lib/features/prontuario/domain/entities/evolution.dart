class Evolution {
  final String id;
  final String patientId;
  final String? studentId;
  final String? studentName;
  final String? professorId;
  final String? professorName;
  final String description;
  final bool isSignedByProfessor;
  final DateTime? signedAt;
  final DateTime createdAt;
  final String? clinicName;

  const Evolution({
    required this.id,
    required this.patientId,
    this.studentId,
    this.studentName,
    this.professorId,
    this.professorName,
    required this.description,
    this.isSignedByProfessor = false,
    this.signedAt,
    required this.createdAt,
    this.clinicName,
  });

  factory Evolution.fromJson(Map<String, dynamic> json) {
    return Evolution(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      studentId: json['studentId'] as String?,
      studentName: json['studentName'] as String?,
      professorId: json['professorId'] as String?,
      professorName: json['professorName'] as String?,
      description: json['description'] as String? ?? '',
      isSignedByProfessor: json['isSignedByProfessor'] as bool? ?? false,
      signedAt: json['signedAt'] != null ? DateTime.parse(json['signedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      clinicName: json['clinicName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'studentId': studentId,
        'studentName': studentName,
        'professorId': professorId,
        'professorName': professorName,
        'description': description,
        'isSignedByProfessor': isSignedByProfessor,
        'signedAt': signedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'clinicName': clinicName,
      };

  Evolution copyWith({
    String? id,
    String? patientId,
    String? studentId,
    String? studentName,
    String? professorId,
    String? professorName,
    String? description,
    bool? isSignedByProfessor,
    DateTime? signedAt,
    DateTime? createdAt,
    String? clinicName,
  }) {
    return Evolution(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      professorId: professorId ?? this.professorId,
      professorName: professorName ?? this.professorName,
      description: description ?? this.description,
      isSignedByProfessor: isSignedByProfessor ?? this.isSignedByProfessor,
      signedAt: signedAt ?? this.signedAt,
      createdAt: createdAt ?? this.createdAt,
      clinicName: clinicName ?? this.clinicName,
    );
  }
}
