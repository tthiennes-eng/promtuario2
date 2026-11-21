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
  final String doctorId;
  final String doctorName;
  final String? observations;
  final DateTime createdAt;

  Prescription({
    required this.id,
    required this.patientId,
    required this.clinicId,
    required this.items,
    required this.doctorId,
    required this.doctorName,
    this.observations,
    DateTime? date,
  }) : createdAt = date ?? DateTime.now();

  DateTime get date => createdAt;

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      clinicId: json['clinicId'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => PrescriptionItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      observations: json['observations'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date']) : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'clinicId': clinicId,
        'items': items.map((e) => e.toJson()).toList(),
        'doctorId': doctorId,
        'doctorName': doctorName,
        'observations': observations,
        'date': createdAt.toIso8601String(),
      };

  Prescription copyWith({
    String? id,
    String? patientId,
    String? clinicId,
    List<PrescriptionItem>? items,
    String? doctorId,
    String? doctorName,
    String? observations,
    DateTime? date,
  }) {
    return Prescription(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      clinicId: clinicId ?? this.clinicId,
      items: items ?? this.items,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      observations: observations ?? this.observations,
      date: date ?? createdAt,
    );
  }
}

class MedicalCertificate {
  final String id;
  final String patientId;
  final String content;
  final int daysOfRest;
  final String doctorId;
  final String doctorName;
  final String? cid;
  final DateTime createdAt;

  MedicalCertificate({
    required this.id,
    required this.patientId,
    required this.content,
    required this.daysOfRest,
    required this.doctorId,
    required this.doctorName,
    this.cid,
    DateTime? date,
  }) : createdAt = date ?? DateTime.now();

  DateTime get date => createdAt;

  factory MedicalCertificate.fromJson(Map<String, dynamic> json) {
    return MedicalCertificate(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      daysOfRest: json['daysOfRest'] as int? ?? 0,
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      cid: json['cid'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date']) : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'content': content,
        'daysOfRest': daysOfRest,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'cid': cid,
        'date': createdAt.toIso8601String(),
      };

  MedicalCertificate copyWith({
    String? id,
    String? patientId,
    String? content,
    int? daysOfRest,
    String? doctorId,
    String? doctorName,
    String? cid,
    DateTime? date,
  }) {
    return MedicalCertificate(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      content: content ?? this.content,
      daysOfRest: daysOfRest ?? this.daysOfRest,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      cid: cid ?? this.cid,
      date: date ?? createdAt,
    );
  }
}
