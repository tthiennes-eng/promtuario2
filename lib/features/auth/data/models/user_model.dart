import '../../domain/entities/user.dart';

/// Modelo de usuário simplificado sem dependência de geração de código (Freezed/JSON)
/// para destravar o ambiente de compilação no Windows.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      name: (json['name'] ?? json['Name'] ?? 'Usuário').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      role: (json['role'] ?? json['Role'] ?? 'aluno').toString(),
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'isActive': isActive,
  };
}

extension UserModelX on UserModel {
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      role: UserRole.parse(role),
      isActive: isActive,
    );
  }
}
