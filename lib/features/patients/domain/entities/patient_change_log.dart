import 'package:promt/core/utils/date_utils.dart';

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

  PatientChangeLog copyWith({
    String? id,
    String? patientId,
    String? userId,
    String? userName,
    DateTime? timestamp,
    String? changesJson,
  }) {
    return PatientChangeLog(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      timestamp: timestamp ?? this.timestamp,
      changesJson: changesJson ?? this.changesJson,
    );
  }

  factory PatientChangeLog.fromJson(Map<String, dynamic> json) {
    String getString(List<String> keys) {
      for (final k in keys) {
        final val = json[k];
        if (val != null && val.toString().isNotEmpty) return val.toString();
      }
      return '';
    }

    return PatientChangeLog(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      patientId: getString(['patientId', 'PatientId', 'patient_id']),
      userId: getString(['userId', 'UserId', 'user_id']),
      userName: getString(['userName', 'UserName', 'user_name']),
      timestamp: SafeDateParser.parse(json['timestamp'] ?? json['Timestamp']),
      changesJson: getString(['changesJson', 'ChangesJson', 'changes']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'userId': userId,
    'userName': userName,
    'timestamp': timestamp.toIso8601String(),
    'changesJson': changesJson,
  };
}
