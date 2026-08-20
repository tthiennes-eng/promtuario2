import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../security/storage_service.dart';
import 'api_client.dart'; // Import necessário para acessar o serverIpProvider

/// Serviço responsável pela comunicação em tempo real via SignalR.
/// Refatorado para suportar IPs dinâmicos e garantir sincronização em rede local.
class RealtimeService {
  final StorageService _storage;
  final String _serverIp; // IP do servidor centralizado
  HubConnection? _hubConnection;
  final _logger = Logger('RealtimeService');

  RealtimeService(this._storage, this._serverIp);

  /// Inicializa a conexão com o Hub do SignalR.
  Future<void> init() async {
    // Evita múltiplas conexões ativas
    if (_hubConnection?.state == HubConnectionState.Connected) return;

    final token = await _storage.getAccessToken();
    if (token == null) {
      _logger.warning('Tentativa de conexão SignalR sem token de acesso.');
      return;
    }

    final httpOptions = HttpConnectionOptions(
      accessTokenFactory: () async => token,
      logMessageContent: kDebugMode,
    );

    // CORREÇÃO: Lógica de URL dinâmica replicando a segurança do ApiClient.
    // Garante que terminais Windows e dispositivos Android (emulador ou físico) 
    // apontem corretamente para o servidor central na rede.
    String url;
    if (defaultTargetPlatform == TargetPlatform.android && 
       (_serverIp == 'localhost' || _serverIp == '127.0.0.1')) {
      // Alias padrão para o host da máquina a partir do emulador Android
      url = 'http://10.0.2.2:5000/hubs/clinic';
    } else {
      // Usa o IP configurado no aplicativo (ex: 192.168.0.3)
      url = 'http://$_serverIp:5000/hubs/clinic';
    }

    _logger.info('Iniciando conexão SignalR em: $url');

    _hubConnection = HubConnectionBuilder()
        .withUrl(url, options: httpOptions)
        .withAutomaticReconnect()
        .build();

    try {
      await _hubConnection?.start();
      _logger.info('Conexão SignalR estabelecida com sucesso.');
    } catch (e) {
      _logger.severe('Falha ao conectar no SignalR: $e');
    }
  }

  /// Registra um ouvinte para eventos enviados pelo servidor.
  void on(String methodName, void Function(List<Object?>?) callback) {
    _hubConnection?.on(methodName, callback);
  }

  /// Encerra a conexão atual.
  Future<void> stop() async {
    await _hubConnection?.stop();
    _hubConnection = null;
    _logger.info('Conexão SignalR encerrada.');
  }
}

/// Provider que gerencia a instância única do RealtimeService.
/// Observa o serverIpProvider para reagir a mudanças de configuração sem reiniciar o app.
final realtimeServiceProvider = Provider((ref) {
  final storage = ref.watch(storageServiceProvider);
  final serverIp = ref.watch(serverIpProvider); // Dependência do IP configurado
  
  return RealtimeService(storage, serverIp);
});
