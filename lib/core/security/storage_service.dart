import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provedor para o serviço de armazenamento seguro.
final storageServiceProvider = Provider((ref) => StorageService());

/// Serviço responsável por persistir dados sensíveis (Tokens) de forma segura.
class StorageService {
  StorageService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _serverIpKey = 'server_ip';
  static const _rememberMeKey = 'remember_me';
  static const _savedEmailKey = 'saved_email';
  static const _savedUserKey = 'saved_user';

  String? _memoryAccessToken;
  String? _memoryRefreshToken;
  String? _memoryUserJson;

  /// Salva a preferência de manter o login salvo.
  Future<void> saveRememberMe(bool value) async {
    await _storage.write(key: _rememberMeKey, value: value ? 'true' : 'false');
  }

  /// Recupera a preferência de manter o login salvo (padrão: true).
  Future<bool> getRememberMe() async {
    final raw = await _storage.read(key: _rememberMeKey);
    if (raw == null) return true;
    return raw == 'true';
  }

  /// Salva o e-mail para preenchimento automático na tela de login.
  Future<void> saveSavedEmail(String email) async {
    await _storage.write(key: _savedEmailKey, value: email);
  }

  /// Recupera o último e-mail salvo.
  Future<String?> getSavedEmail() async => await _storage.read(key: _savedEmailKey);

  /// Remove o e-mail salvo.
  Future<void> clearSavedEmail() async {
    await _storage.delete(key: _savedEmailKey);
  }

  /// Salva os dados serializados do usuário autenticado.
  Future<void> saveUserJson(String userJson, {bool? persist}) async {
    _memoryUserJson = userJson;
    final shouldPersist = persist ?? await getRememberMe();
    if (shouldPersist) {
      await _storage.write(key: _savedUserKey, value: userJson);
    } else {
      await _storage.delete(key: _savedUserKey);
    }
  }

  /// Recupera os dados serializados do usuário salvo.
  Future<String?> getUserJson() async {
    if (_memoryUserJson != null) return _memoryUserJson;
    if (!await getRememberMe()) return null;
    _memoryUserJson = await _storage.read(key: _savedUserKey);
    return _memoryUserJson;
  }

  /// Salva os tokens de autenticação (persiste em disco apenas se rememberMe estiver ativo).
  Future<void> saveTokens({
    required String access,
    required String refresh,
    bool? persist,
  }) async {
    _memoryAccessToken = access;
    _memoryRefreshToken = refresh;
    final shouldPersist = persist ?? await getRememberMe();
    if (shouldPersist) {
      await _storage.write(key: _accessTokenKey, value: access);
      await _storage.write(key: _refreshTokenKey, value: refresh);
    } else {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    }
  }

  /// Recupera o Access Token.
  Future<String?> getAccessToken() async {
    if (_memoryAccessToken != null) return _memoryAccessToken;
    if (!await getRememberMe()) return null;
    _memoryAccessToken = await _storage.read(key: _accessTokenKey);
    return _memoryAccessToken;
  }

  /// Recupera o Refresh Token.
  Future<String?> getRefreshToken() async {
    if (_memoryRefreshToken != null) return _memoryRefreshToken;
    if (!await getRememberMe()) return null;
    _memoryRefreshToken = await _storage.read(key: _refreshTokenKey);
    return _memoryRefreshToken;
  }

  /// Salva o IP do servidor.
  Future<void> saveServerIp(String ip) async {
    await _storage.write(key: _serverIpKey, value: ip);
  }

  /// Recupera o IP do servidor.
  Future<String?> getServerIp() async => await _storage.read(key: _serverIpKey);

  /// Remove todos os dados de sessão ativa.
  Future<void> clearSession() async {
    _memoryAccessToken = null;
    _memoryRefreshToken = null;
    _memoryUserJson = null;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _savedUserKey);
  }
}
