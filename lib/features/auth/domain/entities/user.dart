import 'package:freezed_annotation/freezed_annotation.dart';

// part 'user.freezed.dart';
// part 'user.g.dart';

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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] as String? ?? 'aluno'),
        orElse: () => UserRole.aluno,
      ),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.name,
    'isActive': isActive,
  };
}

enum UserRole {
  @JsonValue('admin') admin,
  @JsonValue('coordenador') coordenador,
  @JsonValue('professor') professor,
  @JsonValue('aluno') aluno,
  @JsonValue('recepcionista') recepcionista,
  @JsonValue('secretaria') secretaria;

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
