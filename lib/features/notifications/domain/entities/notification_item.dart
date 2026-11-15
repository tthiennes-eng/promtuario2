import 'package:freezed_annotation/freezed_annotation.dart';

// Remova as partes comentadas se não for usar o gerador agora para evitar erros de arquivo ausente
// part 'notification_item.freezed.dart';
// part 'notification_item.g.dart';

@freezed
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

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'systemAlert'),
        orElse: () => NotificationType.systemAlert,
      ),
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

enum NotificationType { 
  appointmentReminder, 
  pendingSignature, 
  treatmentApproved, 
  systemAlert,
  info // Caso genérico
}
