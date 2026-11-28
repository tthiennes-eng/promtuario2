import 'package:drift/drift.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/features/auth/data/models/user_model.dart';
import 'package:promt/features/auth/domain/entities/user.dart';
import 'package:promt/features/users/domain/repositories/i_user_management_repository.dart';

/// Implementação do Repositório de Gestão de Usuários com suporte a Cache Offline.
class UserManagementRepository implements IUserManagementRepository {
  final ApiClient _apiClient;
  final AppDatabase _localDb;

  UserManagementRepository(this._apiClient, this._localDb);

  @override
  Future<List<User>> getUsers({UserRole? role, String? query}) async {
    try {
      final response = await _apiClient.instance.get('/users', queryParameters: {
        if (role != null) 'role': role.name,
        if (query != null) 'search': query,
      });

      final data = response.data as List;
      final users = data.map((json) => UserModel.fromJson(json as Map<String, dynamic>).toEntity()).toList();

      await _updateLocalCache(users, replaceAll: role == null && (query == null || query.trim().isEmpty));
      return users;
    } catch (e) {
      final results = await _localDb.select(_localDb.usersLocal).get();
      final trimmedQuery = query?.trim().toLowerCase() ?? '';

      return results
          .map((row) => User(
                id: row.id,
                name: row.name,
                email: row.email,
                role: UserRole.values.firstWhere((e) => e.name == row.role, orElse: () => UserRole.aluno),
                isActive: row.isActive,
              ))
          .where((u) {
            if (role != null && u.role != role) return false;
            if (trimmedQuery.isNotEmpty &&
                !u.name.toLowerCase().contains(trimmedQuery) &&
                !u.email.toLowerCase().contains(trimmedQuery)) {
              return false;
            }
            return true;
          })
          .toList();
    }
  }

  @override
  Future<void> createUser(User user, String password) async {
    await _apiClient.instance.post('/users', data: {
      'name': user.name,
      'email': user.email,
      'password': password,
      'role': user.role.name,
    });
  }

  @override
  Future<void> toggleUserStatus(String userId, bool active) async {
    await _apiClient.instance.patch('/users/$userId/status', data: {'active': active});
  }

  @override
  Future<void> updateUserRole(String userId, UserRole role) async {
    await _apiClient.instance.patch('/users/$userId/role', data: {'role': role.name});
  }

  Future<void> _updateLocalCache(List<User> users, {bool replaceAll = false}) async {
    if (replaceAll) {
      final remoteIds = users.map((u) => u.id).toSet();
      final existing = await _localDb.select(_localDb.usersLocal).get();
      for (final row in existing) {
        if (!remoteIds.contains(row.id)) {
          await (_localDb.delete(_localDb.usersLocal)..where((t) => t.id.equals(row.id))).go();
        }
      }
    }
    for (var user in users) {
      await _localDb.into(_localDb.usersLocal).insertOnConflictUpdate(
        UsersLocalCompanion.insert(
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role.name,
          isActive: Value(user.isActive),
        ),
      );
    }
  }
}
