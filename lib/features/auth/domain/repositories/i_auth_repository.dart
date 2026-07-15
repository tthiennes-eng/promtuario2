import '../entities/user.dart';

/// Contrato para o Repositório de Autenticação.
/// Define as operações necessárias para gestão de sessão e identidade.
abstract class IAuthRepository {
  /// Realiza o login utilizando e-mail e senha.
  /// Retorna o [User] em caso de sucesso ou lança uma exceção.
  Future<User> login(String email, String password);

  /// Realiza o logout, limpando tokens e encerrando a sessão.
  Future<void> logout();

  /// Verifica se existe uma sessão ativa e tenta recuperar o usuário.
  Future<User?> getCurrentUser();

  /// Tenta renovar o access token utilizando o refresh token.
  Future<String?> refreshToken();
}
