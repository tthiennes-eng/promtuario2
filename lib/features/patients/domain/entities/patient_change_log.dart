import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_change_log.freezed.dart';

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

  factory PatientChangeLog.fromJson(Map<String, dynamic> json) {
    return PatientChangeLog(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      patientId: (json['patientId'] ?? json['PatientId'])?.toString() ?? '',
      userId: (json['userId'] ?? json['UserId'])?.toString() ?? '',
      userName: (json['userName'] ?? json['UserName'] ?? 'Usuário') as String,
      timestamp: _safeParse(json['timestamp'] ?? json['Timestamp']),
      changesJson: (json['changesJson'] ?? json['ChangesJson'] ?? '{}') as String,
    );
  }
}
