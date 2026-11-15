import 'package:freezed_annotation/freezed_annotation.dart';

part 'prescription.freezed.dart';
part 'prescription.g.dart';

@freezed
class Prescription with _$Prescription {
  const factory Prescription({
    required String id,
    required String patientId,
    required String clinicId,
    required List<PrescriptionItem> items,
    String? observations,
    required DateTime createdAt,
  }) = _Prescription;

  factory Prescription.fromJson(Map<String, dynamic> json) => _$PrescriptionFromJson(json);
}

@freezed
class PrescriptionItem with _$PrescriptionItem {
  const factory PrescriptionItem({
    required String medicineName,
    required String dosage,
    required String instructions,
  }) = _PrescriptionItem;

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) => _$PrescriptionItemFromJson(json);
}

@freezed
class MedicalCertificate with _$MedicalCertificate {
  const factory MedicalCertificate({
    required String id,
    required String patientId,
    required String content,
    required int daysOfRest,
    String? cid,
    required DateTime createdAt,
  }) = _MedicalCertificate;

  factory MedicalCertificate.fromJson(Map<String, dynamic> json) => _$MedicalCertificateFromJson(json);
}
