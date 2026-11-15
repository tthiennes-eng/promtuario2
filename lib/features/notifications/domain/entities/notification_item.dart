import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_item.freezed.dart';
part 'notification_item.g.dart';

@freezed
class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required String title,
    required String message,
    required NotificationType type,
    required DateTime timestamp,
    @Default(false) bool isRead,
    Map<String, dynamic>? data,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) => _$NotificationItemFromJson(json);
}

enum NotificationType { 
  appointmentReminder, 
  pendingSignature, 
  treatmentApproved, 
  systemAlert,
  info
}
