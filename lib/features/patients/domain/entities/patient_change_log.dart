import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_change_log.freezed.dart';
part 'patient_change_log.g.dart';

@freezed
class PatientChangeLog with _$PatientChangeLog {
  const factory PatientChangeLog({
    required String id,
    required String patientId,
    required String userId,
    required String userName,
    required DateTime timestamp,
    required String changesJson,
  }) = _PatientChangeLog;

  factory PatientChangeLog.fromJson(Map<String, dynamic> json) => _$PatientChangeLogFromJson(json);
}
