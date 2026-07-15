import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/odontogram.dart';
import '../../domain/repositories/i_prontuario_repository.dart';
import '../../../core/providers/providers.dart';

part 'prontuario_viewmodel.g.dart';

@riverpod
class ProntuarioViewModel extends _$ProntuarioViewModel {
  @override
  FutureOr<Odontogram?> build(String patientId) async {
    return _fetchOdontogram(patientId);
  }

  Future<Odontogram?> _fetchOdontogram(String patientId) async {
    final repository = ref.read(prontuarioRepositoryProvider);
    try {
      return await repository.getOdontogram(patientId);
    } catch (e) {
      return null;
    }
  }

  /// Atualiza uma condição específica de um dente no odontograma.
  Future<void> updateToothCondition(ToothCondition condition) async {
    final currentOdontogram = state.value;
    if (currentOdontogram == null) return;

    final updatedTeeth = List<ToothCondition>.from(currentOdontogram.teeth);
    final index = updatedTeeth.indexWhere((t) => t.toothNumber == condition.toothNumber);

    if (index != -1) {
      updatedTeeth[index] = condition;
    } else {
      updatedTeeth.add(condition);
    }

    final updatedOdontogram = currentOdontogram.copyWith(
      teeth: updatedTeeth,
      updatedAt: DateTime.now(),
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(prontuarioRepositoryProvider);
      await repository.saveOdontogram(updatedOdontogram);
      return updatedOdontogram;
    });
  }

  /// Adiciona uma evolução clínica.
  Future<void> addEvolution(String description, String professorId) async {
    final patientId = arg;
    final repository = ref.read(prontuarioRepositoryProvider);
    await repository.addEvolution(patientId, description, professorId);
  }
}
