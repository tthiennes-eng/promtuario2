import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/i_user_management_repository.dart';
import '../../../../core/providers/providers.dart';

part 'user_management_viewmodel.g.dart';

@riverpod
class UserManagementViewModel extends _$UserManagementViewModel {
  @override
  FutureOr<List<User>> build() async {
    return _fetchUsers();
  }

  Future<List<User>> _fetchUsers({UserRole? role, String? query}) async {
    final repository = ref.read(userManagementRepositoryProvider);
    return await repository.getUsers(role: role, query: query);
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUsers(query: query));
  }

  Future<void> filterByRole(UserRole? role) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUsers(role: role));
  }

  Future<void> createUser(User user, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userManagementRepositoryProvider);
      await repository.createUser(user, password);
      return _fetchUsers();
    });
  }

  Future<void> toggleStatus(String userId, bool active) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userManagementRepositoryProvider);
      await repository.toggleUserStatus(userId, active);
      return _fetchUsers();
    });
  }
}
