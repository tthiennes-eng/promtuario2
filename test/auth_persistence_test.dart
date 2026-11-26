import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/security/storage_service.dart';
import 'package:promt/features/auth/data/repositories/auth_repository.dart';

class _InMemorySecureStorage extends FlutterSecureStorage {
  final Map<String, String> backing;
  _InMemorySecureStorage(this.backing);

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      backing.remove(key);
    } else {
      backing[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return backing[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    backing.remove(key);
  }
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient(StorageService storage, this._dio) : super(storage, '127.0.0.1');

  final Dio _dio;

  @override
  Dio get instance => _dio;
}

Dio _buildMockDio({
  required int meStatusCode,
  int refreshStatusCode = 200,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:5000/api/'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path.endsWith('auth/login')) {
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'accessToken': 'access-123',
                'refreshToken': 'refresh-123',
                'user': {
                  'id': 'u-1',
                  'name': 'Administrador Inicial',
                  'email': 'admin@odontoclinica.edu.br',
                  'role': 'admin',
                },
              },
            ),
          );
        }
        if (options.path.endsWith('auth/me')) {
          if (meStatusCode == 200) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 'u-1',
                  'name': 'Administrador Inicial',
                  'email': 'admin@odontoclinica.edu.br',
                  'role': 'admin',
                },
              ),
            );
          }
          return handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: meStatusCode,
              ),
              type: DioExceptionType.badResponse,
            ),
          );
        }
        if (options.path.endsWith('auth/refresh')) {
          if (refreshStatusCode == 200) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'accessToken': 'access-456',
                  'refreshToken': 'refresh-456',
                  'user': {
                    'id': 'u-1',
                    'name': 'Administrador Inicial',
                    'email': 'admin@odontoclinica.edu.br',
                    'role': 'admin',
                  },
                },
              ),
            );
          }
          return handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: refreshStatusCode,
              ),
              type: DioExceptionType.badResponse,
            ),
          );
        }
        if (options.path.endsWith('auth/logout')) {
          return handler.resolve(
            Response(requestOptions: options, statusCode: 204),
          );
        }
        return handler.next(options);
      },
    ),
  );
  return dio;
}

void main() {
  test('rememberMe=true persists session and restores user across app restarts via /auth/me', () async {
    final disk = <String, String>{};
    final storage1 = StorageService(_InMemorySecureStorage(disk));
    final repo1 = AuthRepository(_FakeApiClient(storage1, _buildMockDio(meStatusCode: 200)), storage1);

    final loggedIn = await repo1.login('admin@odontoclinica.edu.br', 'admin123', rememberMe: true);
    expect(loggedIn.email, 'admin@odontoclinica.edu.br');
    expect(disk['access_token'], 'access-123');
    expect(disk['refresh_token'], 'refresh-123');
    expect(disk['remember_me'], 'true');
    expect(disk['saved_email'], 'admin@odontoclinica.edu.br');

    // Simula reabrir o aplicativo (nova instância de StorageService com mesmo armazenamento em disco)
    final storage2 = StorageService(_InMemorySecureStorage(disk));
    final repo2 = AuthRepository(_FakeApiClient(storage2, _buildMockDio(meStatusCode: 200)), storage2);

    final restored = await repo2.getCurrentUser();
    expect(restored, isNotNull);
    expect(restored!.email, 'admin@odontoclinica.edu.br');
  });

  test('rememberMe=true still restores user when /auth/me returns 404 via refresh/cache', () async {
    final disk = <String, String>{};
    final storage1 = StorageService(_InMemorySecureStorage(disk));
    final repo1 = AuthRepository(_FakeApiClient(storage1, _buildMockDio(meStatusCode: 404)), storage1);

    await repo1.login('admin@odontoclinica.edu.br', 'admin123', rememberMe: true);

    final storage2 = StorageService(_InMemorySecureStorage(disk));
    final repo2 = AuthRepository(_FakeApiClient(storage2, _buildMockDio(meStatusCode: 404, refreshStatusCode: 200)), storage2);

    final restored = await repo2.getCurrentUser();
    expect(restored, isNotNull);
    expect(restored!.email, 'admin@odontoclinica.edu.br');
    expect(disk['access_token'], 'access-456');
  });

  test('rememberMe=false keeps tokens in memory only and does not restore after restart', () async {
    final disk = <String, String>{};
    final storage1 = StorageService(_InMemorySecureStorage(disk));
    final repo1 = AuthRepository(_FakeApiClient(storage1, _buildMockDio(meStatusCode: 200)), storage1);

    await repo1.login('admin@odontoclinica.edu.br', 'admin123', rememberMe: false);
    expect(await storage1.getAccessToken(), 'access-123');
    expect(disk['access_token'], isNull);
    expect(disk['saved_email'], isNull);
    expect(disk['remember_me'], 'false');

    // Simula reabrir o aplicativo
    final storage2 = StorageService(_InMemorySecureStorage(disk));
    final repo2 = AuthRepository(_FakeApiClient(storage2, _buildMockDio(meStatusCode: 200)), storage2);

    final restored = await repo2.getCurrentUser();
    expect(restored, isNull);
  });

  test('401 on /auth/me clears invalid session and returns null', () async {
    final disk = <String, String>{};
    final storage1 = StorageService(_InMemorySecureStorage(disk));
    final repo1 = AuthRepository(_FakeApiClient(storage1, _buildMockDio(meStatusCode: 200)), storage1);

    await repo1.login('admin@odontoclinica.edu.br', 'admin123', rememberMe: true);

    final storage2 = StorageService(_InMemorySecureStorage(disk));
    final repo2 = AuthRepository(_FakeApiClient(storage2, _buildMockDio(meStatusCode: 401)), storage2);

    final restored = await repo2.getCurrentUser();
    expect(restored, isNull);
    expect(disk['access_token'], isNull);
  });
}
