import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user.dart';
import '../../../core/providers/providers.dart';

part 'auth_viewmodel.g.dart';

/// Estado da autenticação.
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({this.user, this.isLoading = false, this.errorMessage});

  AuthState copyWith({User? user, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthState build() => AuthState();

  /// Realiza o login.
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(email, password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: 'Falha na autenticação. Verifique suas credenciais.'
      );
    }
  }

  /// Realiza o logout.
  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = AuthState();
  }
}
