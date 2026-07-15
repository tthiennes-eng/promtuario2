import 'package:freezed_annotation/freezed_annotation.dart';

part 'odontogram.freezed.dart';

@freezed
class ToothCondition with _$ToothCondition {
  const factory ToothCondition({
    required int toothNumber, // ISO 3950 (FDI) notation
    required List<ToothSurface> surfaces,
    required ConditionType condition,
    String? observation,
    DateTime? lastUpdate,
  }) = _ToothCondition;
}

enum ToothSurface {
  mesial,
  distal,
  occlusal,
  buccal, // Vestibular
  lingual,
  palatal,
  root,
}

enum ConditionType {
  healthy,
  decayed, // Cárie
  restored, // Restaurado
  missing, // Ausente
  implant,
  endodontic, // Canal
  prosthesis,
}

@freezed
class Odontogram with _$Odontogram {
  const factory Odontogram({
    required String id,
    required String patientId,
    required List<ToothCondition> teeth,
    required DateTime updatedAt,
    required String updatedBy,
  }) = _Odontogram;
}
