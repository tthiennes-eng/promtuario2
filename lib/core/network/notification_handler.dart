import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'realtime_service.dart';
import '../router/app_router.dart';
import '../security/storage_service.dart';

/// Serviço global para gerenciar notificações recebidas via SignalR.
/// Permite exibir alertas visuais em qualquer tela do aplicativo.
class NotificationHandler {
  final Ref _ref;
  bool _initialized = false;

  NotificationHandler(this._ref);

  void init() {
    if (_initialized) return;
    _initialized = true;
    final realtime = _ref.read(realtimeServiceProvider);

    realtime.on('ReceiveNotification', (args) async {
      if (args == null || args.isEmpty) return;
      final pushEnabled = await _ref.read(storageServiceProvider).getPushNotificationsEnabled();
      if (!pushEnabled) return;

      final first = args[0];
      String message;
      if (first is String) {
        message = first;
      } else if (first is Map) {
        message = (first['message'] ?? first['Message'] ?? first['title'] ?? first['Title'] ?? first.toString()).toString();
      } else {
        message = first?.toString() ?? '';
      }
      if (message.trim().isNotEmpty) {
        _showTopSnackBar(message.trim());
      }
    });
  }

  void _showTopSnackBar(String message) {
    final router = _ref.read(routerProvider);
    final context = router.configuration.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF006494),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            router.push('/dashboard/notifications');
          },
        ),
      ),
    );
  }
}

final notificationHandlerProvider = Provider((ref) => NotificationHandler(ref));
