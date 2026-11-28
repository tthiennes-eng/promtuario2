import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../security/storage_service.dart';
import 'api_client.dart';

/// Serviço responsável pela comunicação em tempo real via SignalR.
/// Usa leitura dinâmica do JWT no reconnect e registra listeners mesmo antes de init().
class RealtimeService {
  final StorageService _storage;
  final String _serverIp;
  HubConnection? _hubConnection;
  final Map<String, List<void Function(List<Object?>?)>> _listeners = {};
  final _logger = Logger('RealtimeService');

  RealtimeService(this._storage, this._serverIp);

  /// Inicializa a conexão autenticada com o Hub do SignalR.
  Future<void> init() async {
    if (_hubConnection?.state == HubConnectionState.Connected ||
        _hubConnection?.state == HubConnectionState.Connecting) {
      return;
    }

    final initialToken = await _storage.getAccessToken();
    if (initialToken == null || initialToken.isEmpty) {
      _logger.warning('Tentativa de conexão SignalR sem token de acesso.');
      return;
    }

    final httpOptions = HttpConnectionOptions(
      // Busca sempre o token mais recente (evita reconexão com JWT expirado após refresh)
      accessTokenFactory: () async => (await _storage.getAccessToken()) ?? '',
      logMessageContent: kDebugMode,
    );

    final url = '${ApiClient.resolveOrigin(_serverIp)}/hubs/clinic';
    _logger.info('Iniciando conexão SignalR em: $url');

    final connection = HubConnectionBuilder()
        .withUrl(url, options: httpOptions)
        .withAutomaticReconnect()
        .build();

    // Aplica todos os listeners que já foram registrados antes da inicialização do Hub
    _listeners.forEach((methodName, callbacks) {
      for (final cb in callbacks) {
        connection.on(methodName, cb);
      }
    });

    _hubConnection = connection;

    try {
      await _hubConnection?.start();
      _logger.info('Conexão SignalR estabelecida com sucesso.');
    } catch (e) {
      _logger.severe('Falha ao conectar no SignalR: $e');
    }
  }

  /// Registra um ouvinte para eventos enviados pelo servidor (funciona antes ou depois de init()).
  void on(String methodName, void Function(List<Object?>?) callback) {
    final list = _listeners.putIfAbsent(methodName, () => []);
    if (!list.contains(callback)) {
      list.add(callback);
    }
    _hubConnection?.on(methodName, callback);
  }

  /// Encerra a conexão atual.
  Future<void> stop() async {
    await _hubConnection?.stop();
    _hubConnection = null;
    _logger.info('Conexão SignalR encerrada.');
  }
}

final realtimeServiceProvider = Provider((ref) {
  final storage = ref.watch(storageServiceProvider);
  final serverIp = ref.watch(serverIpProvider);
  final service = RealtimeService(storage, serverIp);
  ref.onDispose(() {
    service.stop();
  });
  return service;
});
