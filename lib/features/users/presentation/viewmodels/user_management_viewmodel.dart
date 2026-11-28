import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/features/auth/domain/entities/user.dart';

/// Gerencia o cadastro e administração de usuários.
class UserManagementViewModel extends StateNotifier<AsyncValue<List<User>>> {
  UserManagementViewModel(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref ref;

  Future<void> _init() async {
    state = await AsyncValue.guard(() => _fetchUsers());
  }

  Future<List<User>> _fetchUsers({UserRole? role, String? query}) async {
    final repository = ref.read(userManagementRepositoryProvider);
    return await repository.getUsers(role: role, query: query);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUsers());
  }

  Future<void> search(String query) async {
    state = await AsyncValue.guard(() => _fetchUsers(query: query));
  }

  Future<void> filterByRole(UserRole? role) async {
    state = await AsyncValue.guard(() => _fetchUsers(role: role));
  }

  Future<void> createUser(User user, String password) async {
    await ref.read(userManagementRepositoryProvider).createUser(user, password);
    state = await AsyncValue.guard(() => _fetchUsers());
  }

  Future<void> toggleStatus(String userId, bool active) async {
    await ref.read(userManagementRepositoryProvider).toggleUserStatus(userId, active);
    state = await AsyncValue.guard(() => _fetchUsers());
  }

  Future<void> updateRole(String userId, UserRole role) async {
    await ref.read(userManagementRepositoryProvider).updateUserRole(userId, role);
    state = await AsyncValue.guard(() => _fetchUsers());
  }
}

final userManagementViewModelProvider = StateNotifierProvider<UserManagementViewModel, AsyncValue<List<User>>>((ref) {
  return UserManagementViewModel(ref);
});
