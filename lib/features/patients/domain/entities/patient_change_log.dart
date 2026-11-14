import 'package:freezed_annotation/freezed_annotation.dart';

// part 'patient_change_log.freezed.dart';
// part 'patient_change_log.g.dart';

@freezed
class PatientChangeLog {
  final String id;
  final String patientId;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final String changesJson;

  const PatientChangeLog({
    required this.id,
    required this.patientId,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.changesJson,
  });

  factory PatientChangeLog.fromJson(Map<String, dynamic> json) {
    return PatientChangeLog(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      changesJson: json['changesJson'] as String? ?? '{}',
    );
  }
}
