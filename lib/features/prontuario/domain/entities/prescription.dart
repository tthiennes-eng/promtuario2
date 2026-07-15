import 'package:freezed_annotation/freezed_annotation.dart';

part 'prescription.freezed.dart';

@freezed
class Prescription with _$Prescription {
  const factory Prescription({
    required String id,
    required String patientId,
    required String doctorId,
    required String doctorName,
    required DateTime date,
    required List<PrescriptionItem> items,
    String? observations,
    required String clinicId,
  }) = _Prescription;
}

@freezed
class PrescriptionItem with _$PrescriptionItem {
  const factory PrescriptionItem({
    required String medicineName,
    required String dosage,
    required String instructions,
  }) = _PrescriptionItem;
}

@freezed
class MedicalCertificate with _$MedicalCertificate {
  const factory MedicalCertificate({
    required String id,
    required String patientId,
    required String doctorId,
    required String doctorName,
    required DateTime date,
    required String content,
    required int daysOfRest,
    required String cid, // Código Internacional de Doenças
    required String clinicId,
  }) = _MedicalCertificate;
}
