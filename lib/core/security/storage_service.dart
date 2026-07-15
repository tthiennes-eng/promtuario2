import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provedor para o serviço de armazenamento seguro.
final storageServiceProvider = Provider((ref) => StorageService());

/// Serviço responsável por persistir dados sensíveis (Tokens) de forma segura.
class StorageService {
  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  /// Salva os tokens de autenticação.
  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _accessTokenKey, value: access);
    await _storage.write(key: _refreshTokenKey, value: refresh);
  }

  /// Recupera o Access Token.
  Future<String?> getAccessToken() async => await _storage.read(key: _accessTokenKey);

  /// Recupera o Refresh Token.
  Future<String?> getRefreshToken() async => await _storage.read(key: _refreshTokenKey);

  /// Remove todos os dados de sessão.
  Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
