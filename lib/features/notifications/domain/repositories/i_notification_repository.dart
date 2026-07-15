import '../entities/notification_item.dart';

/// Contrato para o Repositório de Notificações e Alertas.
abstract class INotificationRepository {
  /// Recupera as notificações do usuário logado.
  Future<List<NotificationItem>> getNotifications();

  /// Marca uma notificação como lida.
  Future<void> markAsRead(String notificationId);

  /// Marca todas as notificações como lidas.
  Future<void> markAllAsRead();

  /// Remove uma notificação.
  Future<void> deleteNotification(String notificationId);
}
