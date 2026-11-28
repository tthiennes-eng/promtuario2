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

  static NotificationType _parseType(dynamic raw) {
    if (raw is int) {
      return switch (raw) {
        1 => NotificationType.appointmentReminder,
        2 => NotificationType.pendingSignature,
        3 => NotificationType.treatmentApproved,
        4 => NotificationType.systemAlert,
        _ => NotificationType.info,
      };
    }
    final s = (raw ?? '').toString().trim();
    final asInt = int.tryParse(s);
    if (asInt != null) return _parseType(asInt);
    return NotificationType.values.firstWhere(
      (e) => e.name.toLowerCase() == s.toLowerCase(),
      orElse: () => NotificationType.info,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedData;
    final rawData = json['data'] ?? json['Data'];
    if (rawData is Map) {
      parsedData = Map<String, dynamic>.from(rawData);
    } else if (json['relatedEntityId'] != null || json['RelatedEntityId'] != null) {
      parsedData = {
        'relatedEntityId': (json['relatedEntityId'] ?? json['RelatedEntityId']).toString(),
      };
    }

    return NotificationItem(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      title: (json['title'] ?? json['Title'] ?? '').toString(),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      type: _parseType(json['type'] ?? json['Type']),
      timestamp: _safeParse(
        json['timestamp'] ?? json['Timestamp'] ?? json['createdAt'] ?? json['CreatedAt'],
      ),
      isRead: (json['isRead'] ?? json['IsRead'] ?? false) as bool,
      data: parsedData,
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
