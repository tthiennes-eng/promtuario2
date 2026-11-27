import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../security/storage_service.dart';

/// Provider que gerencia o IP/URL do servidor.
final serverIpProvider = StateNotifierProvider<ServerIpNotifier, String>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ServerIpNotifier(storage);
});

/// Evento incrementado sempre que o refresh token expira e a sessão é invalidada.
final sessionExpiredSignalProvider = StateProvider<int>((ref) => 0);

class ServerIpNotifier extends StateNotifier<String> {
  final StorageService _storage;

  static const defaultIp = 'localhost';

  ServerIpNotifier(this._storage) : super(defaultIp) {
    _loadIp();
  }

  Future<void> _loadIp() async {
    final savedIp = await _storage.getServerIp();
    if (savedIp != null && savedIp.isNotEmpty) {
      state = savedIp;
    }
  }

  Future<void> updateIp(String newIp) async {
    await _storage.saveServerIp(newIp.trim());
    state = newIp.trim();
  }
}

final apiClientProvider = Provider((ref) {
  final storage = ref.watch(storageServiceProvider);
  final serverIp = ref.watch(serverIpProvider);
  return ApiClient(
    storage,
    serverIp,
    onSessionExpired: () {
      ref.read(sessionExpiredSignalProvider.notifier).state++;
    },
  );
});

class ApiClient {
  final StorageService _storage;
  final String _serverIp;
  final VoidCallback? _onSessionExpired;
  late final Dio _dio;
  Completer<String?>? _refreshCompleter;

  static String resolveOrigin(String rawServerIp) {
    final cleaned = rawServerIp.trim().replaceAll(RegExp(r'/+$'), '');
    if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
      return cleaned;
    }
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        (cleaned == 'localhost' || cleaned == '127.0.0.1')) {
      return 'http://10.0.2.2:5000';
    }
    if (cleaned.contains(':')) {
      return 'http://$cleaned';
    }
    return 'http://$cleaned:5000';
  }

  ApiClient(
    this._storage,
    this._serverIp, {
    VoidCallback? onSessionExpired,
  }) : _onSessionExpired = onSessionExpired {
    final origin = resolveOrigin(_serverIp);
    final baseUrl = '$origin/api/';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          final isRefreshRequest = e.requestOptions.path.contains('auth/refresh') ||
              e.requestOptions.path.contains('auth/login');
          final alreadyRetried = e.requestOptions.extra['_retried'] == true;

          if (e.response?.statusCode == 401 && !isRefreshRequest && !alreadyRetried) {
            final newAccess = await _refreshAccessTokenSerialized();
            if (newAccess != null && newAccess.isNotEmpty) {
              try {
                e.requestOptions.extra['_retried'] = true;
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                final response = await _dio.fetch(e.requestOptions);
                return handler.resolve(response);
              } catch (retryErr) {
                if (retryErr is DioException) {
                  return handler.next(retryErr);
                }
              }
            }
          }
          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
    }
  }

  /// Serializa múltiplas tentativas paralelas de renovação de token 401 em uma única chamada.
  Future<String?> _refreshAccessTokenSerialized() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _storage.clearSession();
        _onSessionExpired?.call();
        completer.complete(null);
        return null;
      }

      final refreshResponse = await Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      ).post('auth/refresh', data: {'refreshToken': refreshToken});

      if (refreshResponse.statusCode == 200 && refreshResponse.data is Map) {
        final newAccess = refreshResponse.data['accessToken']?.toString();
        final newRefresh = refreshResponse.data['refreshToken']?.toString();
        if (newAccess != null && newAccess.isNotEmpty && newRefresh != null && newRefresh.isNotEmpty) {
          await _storage.saveTokens(access: newAccess, refresh: newRefresh);
          completer.complete(newAccess);
          return newAccess;
        }
      }

      await _storage.clearSession();
      _onSessionExpired?.call();
      completer.complete(null);
      return null;
    } catch (_) {
      await _storage.clearSession();
      _onSessionExpired?.call();
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  Dio get instance => _dio;
}
