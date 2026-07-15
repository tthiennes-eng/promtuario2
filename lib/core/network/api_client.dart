import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../security/storage_service.dart';

/// Provedor global do cliente HTTP Dio.
final apiClientProvider = Provider((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storage);
});

/// Cliente HTTP configurado com interceptors para logs, 
/// autenticação JWT e auto-refresh de token.
class ApiClient {
  final StorageService _storage;
  late final Dio _dio;

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.odontoclinica.edu.br/api', // URL base definida para o backend
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
        // Se receber 401 (Não autorizado), tenta renovar o token
        if (e.response?.statusCode == 401) {
          final refreshToken = await _storage.getRefreshToken();
          
          if (refreshToken != null) {
            try {
              // Requisição isolada para não entrar no interceptor recursivamente
              final refreshResponse = await Dio(BaseOptions(baseUrl: _dio.options.baseUrl))
                  .post('/auth/refresh', data: {'refreshToken': refreshToken});

              if (refreshResponse.statusCode == 200) {
                final newAccessToken = refreshResponse.data['accessToken'];
                final newRefreshToken = refreshResponse.data['refreshToken'];

                await _storage.saveTokens(access: newAccessToken, refresh: newRefreshToken);

                // Refaz a requisição original com o novo token
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final response = await _dio.fetch(e.requestOptions);
                return handler.resolve(response);
              }
            } catch (refreshError) {
              // Se falhar o refresh, limpa sessão e redireciona (via router listenable)
              await _storage.clearSession();
            }
          }
        }
        return handler.next(e);
      },
    ));
    
    // Adicionar log em desenvolvimento
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Dio get instance => _dio;
}
