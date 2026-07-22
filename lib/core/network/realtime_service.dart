import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../security/storage_service.dart';

class RealtimeService {
  final StorageService _storage;
  HubConnection? _hubConnection;
  final _logger = Logger('RealtimeService');

  RealtimeService(this._storage);

  Future<void> init() async {
    if (_hubConnection?.state == HubConnectionState.Connected) return;

    final token = await _storage.getAccessToken();
    if (token == null) return;

    final httpOptions = HttpConnectionOptions(
      accessTokenFactory: () async => token,
      logMessageContent: kDebugMode,
    );

    // Ajustado para o servidor local
    final url = kIsWeb || defaultTargetPlatform == TargetPlatform.windows 
        ? 'http://localhost:5000/hubs/clinic' 
        : 'http://10.0.2.2:5000/hubs/clinic';

    _hubConnection = HubConnectionBuilder()
        .withUrl(url, options: httpOptions)
        .withAutomaticReconnect()
        .build();

    try {
      await _hubConnection?.start();
      _logger.info('Conexão SignalR estabelecida.');
    } catch (e) {
      _logger.severe('Erro SignalR: $e');
    }
  }

  void on(String methodName, void Function(List<Object?>?) callback) {
    _hubConnection?.on(methodName, callback);
  }

  Future<void> stop() async {
    await _hubConnection?.stop();
    _hubConnection = null;
  }
}

final realtimeServiceProvider = Provider((ref) {
  final storage = ref.watch(storageServiceProvider);
  return RealtimeService(storage);
});
