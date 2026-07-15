import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/anamnese.dart';
import '../../domain/repositories/i_prontuario_repository.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../../core/providers/providers.dart';

part 'anamnese_viewmodel.g.dart';

/// Gerencia o estado da Ficha de Anamnese do paciente.
/// Garante que o histórico de saúde seja persistido com o ID do profissional logado.
@riverpod
class AnamneseViewModel extends _$AnamneseViewModel {
  @override
  FutureOr<Anamnese?> build(String patientId) async {
    return _fetchAnamnese(patientId);
  }

  Future<Anamnese?> _fetchAnamnese(String patientId) async {
    final repository = ref.read(prontuarioRepositoryProvider);
    return await repository.getAnamneseByPatientId(patientId);
  }

  /// Salva ou atualiza a anamnese utilizando o ID do usuário autenticado.
  Future<void> saveAnamnese(Map<String, dynamic> responses) async {
    final authState = ref.read(authViewModelProvider);
    final user = authState.user;
    
    if (user == null) {
      state = AsyncValue.error('Usuário não autenticado', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(prontuarioRepositoryProvider);
      final currentAnamnese = state.value;
      
      final anamnese = Anamnese(
        id: currentAnamnese?.id ?? '',
        patientId: arg,
        responses: responses,
        createdAt: currentAnamnese?.createdAt ?? DateTime.now(),
        createdBy: user.id,
      );
      
      await repository.saveAnamnese(anamnese);
      return _fetchAnamnese(arg);
    });
  }
}
