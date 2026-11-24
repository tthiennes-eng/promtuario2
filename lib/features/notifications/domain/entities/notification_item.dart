enum NotificationType {
  appointmentReminder,
  pendingSignature,
  treatmentApproved,
  systemAlert,
  info,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

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

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      title: (json['title'] ?? json['Title'] ?? '') as String,
      message: (json['message'] ?? json['Message'] ?? '') as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == (json['type'] ?? json['Type']),
        orElse: () => NotificationType.info,
      ),
      timestamp: _safeParse(json['timestamp'] ?? json['Timestamp']),
      isRead: (json['isRead'] ?? json['IsRead'] ?? false) as bool,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'data': data,
      };
}
