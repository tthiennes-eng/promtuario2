import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../security/storage_service.dart';

/// Provider que gerencia o IP do servidor.
final serverIpProvider = StateNotifierProvider<ServerIpNotifier, String>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ServerIpNotifier(storage);
});

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
    await _storage.saveServerIp(newIp);
    state = newIp;
  }
}

final apiClientProvider = Provider((ref) {
  final storage = ref.watch(storageServiceProvider);
  final serverIp = ref.watch(serverIpProvider);
  return ApiClient(storage, serverIp);
});

class ApiClient {
  final StorageService _storage;
  final String _serverIp;
  late final Dio _dio;

  ApiClient(this._storage, this._serverIp) {
    String baseUrl;
    
    if (kIsWeb) {
      baseUrl = 'http://$_serverIp:5000/api/';
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          if (_serverIp == 'localhost' || _serverIp == '127.0.0.1') {
            baseUrl = 'http://10.0.2.2:5000/api/';
          } else {
            baseUrl = 'http://$_serverIp:5000/api/';
          }
          break;
        case TargetPlatform.windows:
          if (_serverIp == 'localhost' || _serverIp == '127.0.0.1') {
            baseUrl = 'http://localhost:5000/api/';
          } else {
            baseUrl = 'http://$_serverIp:5000/api/';
          }
          break;
        default:
          baseUrl = 'http://$_serverIp:5000/api/';
      }
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final refreshToken = await _storage.getRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              final refreshResponse = await Dio(
                BaseOptions(
                  baseUrl: _dio.options.baseUrl,
                  connectTimeout: const Duration(seconds: 5),
                  receiveTimeout: const Duration(seconds: 5),
                ),
              ).post('auth/refresh', data: {'refreshToken': refreshToken});

              if (refreshResponse.statusCode == 200) {
                final newAccess = refreshResponse.data['accessToken'];
                final newRefresh = refreshResponse.data['refreshToken'];
                await _storage.saveTokens(access: newAccess, refresh: newRefresh);
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                final response = await _dio.fetch(e.requestOptions);
                return handler.resolve(response);
              }
            } catch (refreshError) {
              await _storage.clearSession();
            }
          } else {
            await _storage.clearSession();
          }
        }
        return handler.next(e);
      },
    ));
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    }
  }

  Dio get instance => _dio;
}
