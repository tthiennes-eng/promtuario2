/// Entidade de domínio representando um Usuário no sistema.
/// Seguindo DDD, esta classe contém apenas lógica de domínio e dados puros.
class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
  });
}

/// Enumeração de papéis (RBAC) conforme especificado nos requisitos.
enum UserRole {
  admin,
  coordenador,
  professor,
  aluno,
  recepcionista,
  secretaria;

  String get displayName {
    return switch (this) {
      admin => 'Administrador',
      coordenador => 'Coordenador',
      professor => 'Professor',
      aluno => 'Aluno',
      recepcionista => 'Recepcionista',
      secretaria => 'Secretaria',
    };
  }
}
