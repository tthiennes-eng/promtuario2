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
      changesJson: json['changesJson'] as String? ?? '',
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
}
