import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    required String role,
    @Default(true) bool isActive,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

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
