import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

// part 'user_model.freezed.dart';
// part 'user_model.g.dart';

@freezed
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
      role: json['role'] as String? ?? 'aluno',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

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
}
