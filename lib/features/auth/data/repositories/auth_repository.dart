import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/security/storage_service.dart';
import 'package:promt/features/auth/domain/entities/user.dart';
import 'package:promt/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:promt/features/auth/data/models/user_model.dart';

/// Implementação concreta do repositório de autenticação.
class AuthRepository implements IAuthRepository {
  final ApiClient _apiClient;
  final StorageService _storage;

  AuthRepository(this._apiClient, this._storage);

  @override
  Future<User> login(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    try {
      final response = await _apiClient.instance.post('auth/login', data: {
        'email': email,
        'password': password,
      });

      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      final userModel = UserModel.fromJson(
        Map<String, dynamic>.from(response.data['user'] as Map),
      );
      final user = userModel.toEntity();

      await _storage.saveRememberMe(rememberMe);
      await _storage.saveTokens(
        access: accessToken,
        refresh: refreshToken,
        persist: rememberMe,
      );
      await _storage.saveUserJson(
        jsonEncode(user.toJson()),
        persist: rememberMe,
      );
      if (rememberMe) {
        await _storage.saveSavedCredentials(email: email, password: password);
      } else {
        await _storage.clearSavedCredentials();
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.instance.post('auth/logout');
    } catch (_) {
      // Mesmo offline ou com token expirado, garante limpeza da sessão local.
    } finally {
      await _storage.clearSession();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final rememberMe = await _storage.getRememberMe();
    if (!rememberMe) {
      await _storage.clearSession();
      return null;
    }

    final token = await _storage.getAccessToken();
    final savedRefresh = await _storage.getRefreshToken();
    if ((token == null || token.isEmpty) &&
        (savedRefresh == null || savedRefresh.isEmpty)) {
      return null;
    }

    try {
      final response = await _apiClient.instance.get(
        'auth/me',
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final user = UserModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ).toEntity();
      await _storage.saveUserJson(jsonEncode(user.toJson()), persist: true);
      return user;
    } on DioException catch (e) {
      // Se o servidor retornou 401 mesmo após tentativa de refresh pelo interceptor,
      // a sessão foi invalidada e não deve ser restaurada.
      if (e.response?.statusCode == 401) {
        await _storage.clearSession();
        return null;
      }

      // Se falhou por rede/timeout, evita esperar um segundo timeout e usa o cache local.
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return _readSavedUser();
      }

      // Em caso de backend sem /auth/me atualizado (ex: 404), tenta renovar via refresh token.
      final refreshed = await _tryRefreshAndReadUser();
      if (refreshed != null) return refreshed;
      return _readSavedUser();
    } catch (_) {
      return _readSavedUser();
    }
  }

  Future<User?> _tryRefreshAndReadUser() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return null;

    try {
      final response = await _apiClient.instance.post('auth/refresh', data: {
        'refreshToken': refresh,
      });

      final newAccess = response.data['accessToken'] as String?;
      final newRefresh = response.data['refreshToken'] as String?;
      if (newAccess != null && newRefresh != null) {
        await _storage.saveTokens(
          access: newAccess,
          refresh: newRefresh,
          persist: true,
        );
      }

      if (response.data['user'] is Map) {
        final user = UserModel.fromJson(
          Map<String, dynamic>.from(response.data['user'] as Map),
        ).toEntity();
        await _storage.saveUserJson(jsonEncode(user.toJson()), persist: true);
        return user;
      }
      return await _readSavedUser();
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        await _storage.clearSession();
        return null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<User?> _readSavedUser() async {
    final currentToken = await _storage.getAccessToken();
    if (currentToken == null || currentToken.isEmpty) return null;

    final rawUser = await _storage.getUserJson();
    if (rawUser == null || rawUser.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawUser);
      if (decoded is Map<String, dynamic>) {
        return User.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<String?> refreshToken() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh == null) return null;

    try {
      final response = await _apiClient.instance.post('auth/refresh', data: {
        'refreshToken': refresh,
      });

      final newAccess = response.data['accessToken'];
      final newRefresh = response.data['refreshToken'];

      await _storage.saveTokens(access: newAccess, refresh: newRefresh);
      if (response.data['user'] is Map) {
        final user = UserModel.fromJson(
          Map<String, dynamic>.from(response.data['user'] as Map),
        ).toEntity();
        await _storage.saveUserJson(jsonEncode(user.toJson()));
      }
      return newAccess;
    } catch (e) {
      await _storage.clearSession();
      return null;
    }
  }
}
