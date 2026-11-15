class PrescriptionItem {
  final String medicineName;
  final String dosage;
  final String instructions;

  const PrescriptionItem({
    required this.medicineName,
    required this.dosage,
    required this.instructions,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      medicineName: json['medicineName'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'medicineName': medicineName,
        'dosage': dosage,
        'instructions': instructions,
      };

  PrescriptionItem copyWith({
    String? medicineName,
    String? dosage,
    String? instructions,
  }) {
    return PrescriptionItem(
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
    );
  }
}

class Prescription {
  final String id;
  final String patientId;
  final String clinicId;
  final List<PrescriptionItem> items;
  final String? observations;
  final DateTime createdAt;

  const Prescription({
    required this.id,
    required this.patientId,
    required this.clinicId,
    required this.items,
    this.observations,
    required this.createdAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      clinicId: json['clinicId'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => PrescriptionItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      observations: json['observations'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'clinicId': clinicId,
        'items': items.map((e) => e.toJson()).toList(),
        'observations': observations,
        'createdAt': createdAt.toIso8601String(),
      };

  Prescription copyWith({
    String? id,
    String? patientId,
    String? clinicId,
    List<PrescriptionItem>? items,
    String? observations,
    DateTime? createdAt,
  }) {
    return Prescription(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      clinicId: clinicId ?? this.clinicId,
      items: items ?? this.items,
      observations: observations ?? this.observations,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MedicalCertificate {
  final String id;
  final String patientId;
  final String content;
  final int daysOfRest;
  final String? cid;
  final DateTime createdAt;

  const MedicalCertificate({
    required this.id,
    required this.patientId,
    required this.content,
    required this.daysOfRest,
    this.cid,
    required this.createdAt,
  });

  factory MedicalCertificate.fromJson(Map<String, dynamic> json) {
    return MedicalCertificate(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      daysOfRest: json['daysOfRest'] as int? ?? 0,
      cid: json['cid'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'content': content,
        'daysOfRest': daysOfRest,
        'cid': cid,
        'createdAt': createdAt.toIso8601String(),
      };

  MedicalCertificate copyWith({
    String? id,
    String? patientId,
    String? content,
    int? daysOfRest,
    String? cid,
    DateTime? createdAt,
  }) {
    return MedicalCertificate(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      content: content ?? this.content,
      daysOfRest: daysOfRest ?? this.daysOfRest,
      cid: cid ?? this.cid,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
