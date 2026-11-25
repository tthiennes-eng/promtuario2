import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/notifications/domain/entities/notification_item.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/core/network/realtime_service.dart';

/// Gerencia as notificações em tempo real.
class NotificationViewModel extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  NotificationViewModel(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref ref;

  Future<void> _init() async {
    _setupRealtime();
    await refresh();
  }

  void _setupRealtime() {
    final realtime = ref.read(realtimeServiceProvider);
    realtime.on('ReceiveNotification', (_) => refresh());
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(notificationRepositoryProvider);
      return await repo.getNotifications();
    });
  }

  Future<void> markAsRead(String id) async {
    await ref.read(notificationRepositoryProvider).markAsRead(id);
    await refresh();
  }

  Future<void> markAllAsRead() async {
    await ref.read(notificationRepositoryProvider).markAllAsRead();
    await refresh();
  }
}

final notificationViewModelProvider = StateNotifierProvider<NotificationViewModel, AsyncValue<List<NotificationItem>>>((ref) {
  return NotificationViewModel(ref);
});
