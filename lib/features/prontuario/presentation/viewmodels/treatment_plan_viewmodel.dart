import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/treatment_plan.dart';
import '../../domain/repositories/i_prontuario_repository.dart';
import '../../../../core/providers/providers.dart';

part 'treatment_plan_viewmodel.g.dart';

/// Gerencia o estado do Plano de Tratamento do paciente.
/// Permite propor procedimentos, acompanhar execuções e gerenciar aprovações.
@riverpod
class TreatmentPlanViewModel extends _$TreatmentPlanViewModel {
  @override
  FutureOr<TreatmentPlan?> build(String patientId) async {
    return _fetchPlan(patientId);
  }

  Future<TreatmentPlan?> _fetchPlan(String patientId) async {
    final repository = ref.read(prontuarioRepositoryProvider);
    return await repository.getTreatmentPlan(patientId);
  }

  /// Persiste as alterações no plano de tratamento ou cria um novo registro.
  Future<void> savePlan(TreatmentPlan plan) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(prontuarioRepositoryProvider);
      await repository.saveTreatmentPlan(plan);
      return _fetchPlan(arg);
    });
  }

  /// Adiciona um novo item (procedimento) ao plano de tratamento atual.
  Future<void> addItem(TreatmentItem item) async {
    final currentPlan = state.value;
    if (currentPlan == null) return;

    final updatedItems = List<TreatmentItem>.from(currentPlan.items)..add(item);
    final updatedPlan = currentPlan.copyWith(
      items: updatedItems, 
      updatedAt: DateTime.now(),
    );
    
    await savePlan(updatedPlan);
  }

  /// Atualiza o status de um item específico (ex: marcar como executado).
  Future<void> updateItemStatus(String itemId, TreatmentItemStatus status) async {
    final currentPlan = state.value;
    if (currentPlan == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(prontuarioRepositoryProvider);
      await repository.updateTreatmentItemStatus(currentPlan.id, itemId, status.name);
      return _fetchPlan(arg);
    });
  }

  /// Aprova formalmente o plano de tratamento (Ação restrita a Professores/Coordenadores).
  Future<void> approvePlan() async {
    final currentPlan = state.value;
    if (currentPlan == null) return;

    final updatedPlan = currentPlan.copyWith(
      status: TreatmentPlanStatus.approved,
      updatedAt: DateTime.now(),
    );

    await savePlan(updatedPlan);
  }
}
