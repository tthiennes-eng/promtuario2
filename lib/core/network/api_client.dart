import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../security/storage_service.dart';

final apiClientProvider = Provider((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storage);
});

class ApiClient {
  final StorageService _storage;
  late final Dio _dio;

  ApiClient(this._storage) {
    String baseUrl;
    // Adicionada a barra '/' ao final de todas as baseUrls
    if (kIsWeb) {
      baseUrl = 'http://localhost:5000/api/';
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          baseUrl = 'http://10.0.2.2:5000/api/';
          break;
        default:
          baseUrl = 'http://localhost:5000/api/';
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
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final refreshToken = await _storage.getRefreshToken();
          if (refreshToken != null) {
            try {
              final refreshResponse = await Dio(BaseOptions(baseUrl: _dio.options.baseUrl))
                  .post('auth/refresh', data: {'refreshToken': refreshToken});

              if (refreshResponse.statusCode == 200) {
                final newAccess = refreshResponse.data['accessToken'];
                final newRefresh = refreshResponse.data['refreshToken'];
                await _storage.saveTokens(access: newAccess, refresh: newRefresh);
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                final response = await _dio.fetch(e.requestOptions);
                return handler.resolve(response);
              }
            } catch (_) {
              await _storage.clearSession();
            }
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
