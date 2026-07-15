import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../features/auth/domain/entities/user.dart'; // To use the Specialty enum if shared or similar

part 'procedure.freezed.dart';
part 'procedure.g.dart';

@freezed
class Procedure with _$Procedure {
  const factory Procedure({
    required String id,
    required String name,
    required String code,
    required double baseValue,
    required String specialty, // Corresponding to the Specialty enum on backend
    required int estimatedTimeMinutes,
  }) = _Procedure;

  factory Procedure.fromJson(Map<String, dynamic> json) => _$ProcedureFromJson(json);
}
