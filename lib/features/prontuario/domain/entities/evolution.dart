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

  factory Evolution.fromJson(Map<String, dynamic> json) {
    return Evolution(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      patientId: (json['patientId'] ?? json['PatientId'])?.toString() ?? '',
      studentId: (json['studentId'] ?? json['StudentId'])?.toString(),
      studentName: (json['studentName'] ?? json['StudentName'])?.toString(),
      professorId: (json['professorId'] ?? json['ProfessorId'])?.toString(),
      professorName: (json['professorName'] ?? json['ProfessorName'])?.toString(),
      description: (json['description'] ?? json['Description'] ?? '') as String,
      isSignedByProfessor: (json['isSignedByProfessor'] ?? json['IsSignedByProfessor'] ?? false) as bool,
      signedAt: (json['signedAt'] ?? json['SignedAt']) != null ? _safeParse(json['signedAt'] ?? json['SignedAt']) : null,
      createdAt: _safeParse(json['createdAt'] ?? json['CreatedAt']),
      clinicName: (json['clinicName'] ?? json['ClinicName']) as String?,
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
