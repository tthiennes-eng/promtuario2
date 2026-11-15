import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'isActive': isActive,
      };

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      role: UserRole.values.firstWhere(
        (e) => e.name == role,
        orElse: () => UserRole.aluno,
      ),
      isActive: isActive,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}
