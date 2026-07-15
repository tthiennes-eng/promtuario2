import '../../auth/domain/entities/user.dart';

/// Contrato para gestão de usuários e perfis (RBAC).
abstract class IUserManagementRepository {
  /// Lista todos os usuários com filtros de papel e busca.
  Future<List<User>> getUsers({UserRole? role, String? query});

  /// Cadastra um novo usuário no sistema (Aluno, Professor, etc).
  Future<void> createUser(User user, String password);

  /// Altera o status de um usuário (Ativar/Desativar).
  Future<void> toggleUserStatus(String userId, bool active);

  /// Atualiza as permissões de um usuário.
  Future<void> updateUserRole(String userId, UserRole role);
}
