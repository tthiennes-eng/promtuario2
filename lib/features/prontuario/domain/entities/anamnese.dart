import 'package:freezed_annotation/freezed_annotation.dart';

part 'anamnese.freezed.dart';
part 'anamnese.g.dart';

@freezed
class Anamnese with _$Anamnese {
  const factory Anamnese({
    required String id,
    required String patientId,
    required Map<String, dynamic> responses, // JSON flexível para as perguntas
    required DateTime createdAt,
    required String createdBy,
    DateTime? updatedAt,
  }) = _Anamnese;

  factory Anamnese.fromJson(Map<String, dynamic> json) => _$AnamneseFromJson(json);
}
