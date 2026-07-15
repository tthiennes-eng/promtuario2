import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/i_user_management_repository.dart';

class UserManagementRepository implements IUserManagementRepository {
  final ApiClient _apiClient;

  UserManagementRepository(this._apiClient);

  @override
  Future<List<User>> getUsers({UserRole? role, String? query}) async {
    final response = await _apiClient.instance.get('/users', queryParameters: {
      if (role != null) 'role': role.name,
      if (query != null) 'search': query,
    });

    final List<dynamic> data = response.data;
    return data.map((json) => UserModel.fromJson(json).toEntity()).toList();
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
}
