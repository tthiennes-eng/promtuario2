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
      medicineName: (json['medicineName'] ?? json['MedicineName'] ?? '') as String,
      dosage: (json['dosage'] ?? json['Dosage'] ?? '') as String,
      instructions: (json['instructions'] ?? json['Instructions'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'medicineName': medicineName,
        'dosage': dosage,
        'instructions': instructions,
      };
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

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      patientId: (json['patientId'] ?? json['PatientId'])?.toString() ?? '',
      clinicId: (json['clinicId'] ?? json['ClinicId'])?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => PrescriptionItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      doctorId: (json['doctorId'] ?? json['DoctorId'])?.toString() ?? '',
      doctorName: (json['doctorName'] ?? json['DoctorName'] ?? '') as String,
      observations: (json['observations'] ?? json['Observations']) as String?,
      date: _safeParse(json['date'] ?? json['Date'] ?? json['createdAt'] ?? json['CreatedAt']),
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

  factory MedicalCertificate.fromJson(Map<String, dynamic> json) {
    return MedicalCertificate(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      patientId: (json['patientId'] ?? json['PatientId'])?.toString() ?? '',
      content: (json['content'] ?? json['Content'] ?? '') as String,
      daysOfRest: (json['daysOfRest'] ?? json['DaysOfRest'] ?? 0) as int,
      doctorId: (json['doctorId'] ?? json['DoctorId'])?.toString() ?? '',
      doctorName: (json['doctorName'] ?? json['DoctorName'] ?? '') as String,
      cid: (json['cid'] ?? json['CID']) as String?,
      date: _safeParse(json['date'] ?? json['Date'] ?? json['createdAt'] ?? json['CreatedAt']),
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
}
