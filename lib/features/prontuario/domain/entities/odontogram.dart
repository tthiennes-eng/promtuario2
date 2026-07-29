import 'package:freezed_annotation/freezed_annotation.dart';

part 'odontogram.freezed.dart';
part 'odontogram.g.dart';

@freezed
class ToothCondition with _$ToothCondition {
  const factory ToothCondition({
    required int toothNumber,
    required List<ToothSurface> surfaces,
    required ConditionType condition,
    String? observation,
    DateTime? lastUpdate,
  }) = _ToothCondition;

  factory ToothCondition.fromJson(Map<String, dynamic> json) => _$ToothConditionFromJson(json);
}

enum ToothSurface {
  @JsonValue('Mesial') mesial,
  @JsonValue('Distal') distal,
  @JsonValue('Occlusal') occlusal,
  @JsonValue('Buccal') buccal,
  @JsonValue('Lingual') lingual,
  @JsonValue('Palatal') palatal,
  @JsonValue('Root') root
}

enum ConditionType {
  @JsonValue('Healthy') healthy,
  @JsonValue('Decayed') decayed,
  @JsonValue('Restored') restored,
  @JsonValue('Missing') missing,
  @JsonValue('Implant') implant,
  @JsonValue('Endodontic') endodontic,
  @JsonValue('Prosthesis') prosthesis
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

  factory Odontogram.fromJson(Map<String, dynamic> json) => _$OdontogramFromJson(json);

  Map<String, dynamic> toJson() => _$$OdontogramImplToJson(this as _$OdontogramImpl);
}
