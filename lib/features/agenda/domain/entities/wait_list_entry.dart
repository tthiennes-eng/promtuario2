class WaitListEntry {
  final String id;
  final String patientId;
  final String patientName;
  final String clinicId;
  final String priority;
  final String specialty;
  final String? observation;
  final DateTime createdAt;

  const WaitListEntry({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.clinicId,
    required this.priority,
    required this.specialty,
    this.observation,
    required this.createdAt,
  });

  factory WaitListEntry.fromJson(Map<String, dynamic> json) {
    return WaitListEntry(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      clinicId: json['clinicId'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      observation: json['observation'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'patientName': patientName,
        'clinicId': clinicId,
        'priority': priority,
        'specialty': specialty,
        'observation': observation,
        'createdAt': createdAt.toIso8601String(),
      };

  WaitListEntry copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? clinicId,
    String? priority,
    String? specialty,
    String? observation,
    DateTime? createdAt,
  }) {
    return WaitListEntry(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      clinicId: clinicId ?? this.clinicId,
      priority: priority ?? this.priority,
      specialty: specialty ?? this.specialty,
      observation: observation ?? this.observation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
