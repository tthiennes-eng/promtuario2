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
  static const _savedPasswordKey = 'saved_password';
  static const _savedUserKey = 'saved_user';

  String? _memoryAccessToken;
  String? _memoryRefreshToken;
  String? _memoryUserJson;

  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _safeWrite(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {}
  }

  Future<void> _safeDelete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  /// Salva a preferência de manter o login salvo.
  Future<void> saveRememberMe(bool value) async {
    await _safeWrite(_rememberMeKey, value ? 'true' : 'false');
  }

  /// Recupera a preferência de manter o login salvo (padrão: true).
  Future<bool> getRememberMe() async {
    final raw = await _safeRead(_rememberMeKey);
    if (raw == null) return true;
    return raw == 'true';
  }

  /// Salva e-mail e senha para preenchimento automático na tela de login.
  Future<void> saveSavedCredentials({
    required String email,
    required String password,
  }) async {
    await _safeWrite(_savedEmailKey, email);
    await _safeWrite(_savedPasswordKey, password);
  }

  /// Salva o e-mail para preenchimento automático na tela de login.
  Future<void> saveSavedEmail(String email) async {
    await _safeWrite(_savedEmailKey, email);
  }

  /// Recupera o último e-mail salvo.
  Future<String?> getSavedEmail() async => await _safeRead(_savedEmailKey);

  /// Recupera a última senha salva.
  Future<String?> getSavedPassword() async => await _safeRead(_savedPasswordKey);

  /// Remove o e-mail salvo.
  Future<void> clearSavedEmail() async {
    await _safeDelete(_savedEmailKey);
  }

  /// Remove e-mail e senha salvos.
  Future<void> clearSavedCredentials() async {
    await _safeDelete(_savedEmailKey);
    await _safeDelete(_savedPasswordKey);
  }

  /// Salva os dados serializados do usuário autenticado.
  Future<void> saveUserJson(String userJson, {bool? persist}) async {
    _memoryUserJson = userJson;
    final shouldPersist = persist ?? await getRememberMe();
    if (shouldPersist) {
      await _safeWrite(_savedUserKey, userJson);
    } else {
      await _safeDelete(_savedUserKey);
    }
  }

  /// Recupera os dados serializados do usuário salvo.
  Future<String?> getUserJson() async {
    if (_memoryUserJson != null) return _memoryUserJson;
    if (!await getRememberMe()) return null;
    _memoryUserJson = await _safeRead(_savedUserKey);
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
      await _safeWrite(_accessTokenKey, access);
      await _safeWrite(_refreshTokenKey, refresh);
    } else {
      await _safeDelete(_accessTokenKey);
      await _safeDelete(_refreshTokenKey);
    }
  }

  /// Recupera o Access Token.
  Future<String?> getAccessToken() async {
    if (_memoryAccessToken != null) return _memoryAccessToken;
    if (!await getRememberMe()) return null;
    _memoryAccessToken = await _safeRead(_accessTokenKey);
    return _memoryAccessToken;
  }

  /// Recupera o Refresh Token.
  Future<String?> getRefreshToken() async {
    if (_memoryRefreshToken != null) return _memoryRefreshToken;
    if (!await getRememberMe()) return null;
    _memoryRefreshToken = await _safeRead(_refreshTokenKey);
    return _memoryRefreshToken;
  }

  /// Salva o IP do servidor.
  Future<void> saveServerIp(String ip) async {
    await _safeWrite(_serverIpKey, ip);
  }

  /// Recupera o IP do servidor.
  Future<String?> getServerIp() async => await _safeRead(_serverIpKey);

  /// Remove todos os dados de sessão ativa.
  Future<void> clearSession() async {
    _memoryAccessToken = null;
    _memoryRefreshToken = null;
    _memoryUserJson = null;
    await _safeDelete(_accessTokenKey);
    await _safeDelete(_refreshTokenKey);
    await _safeDelete(_savedUserKey);
  }
}
