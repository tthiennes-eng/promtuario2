import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/prontuario/domain/entities/treatment_plan.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:uuid/uuid.dart';

/// Gerencia os planos de tratamento dos pacientes.
class TreatmentPlanViewModel extends StateNotifier<AsyncValue<List<TreatmentPlan>>> {
  final Ref ref;
  final String patientId;

  TreatmentPlanViewModel(this.ref, this.patientId) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = await AsyncValue.guard(() => 
      ref.read(prontuarioRepositoryProvider).getTreatmentPlans(patientId)
    );
  }

  Future<void> refresh() async => _init();

  /// Adiciona um item ao plano de tratamento.
  Future<void> addItem(TreatmentItem item) async {
    final currentState = state.value;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (currentState == null || currentState.isEmpty) {
        final authState = ref.read(authViewModelProvider);
        final plan = TreatmentPlan(
          id: const Uuid().v4(),
          patientId: patientId,
          description: 'Plano de tratamento',
          items: [item],
          createdByUserId: authState.user?.id ?? 'system',
          status: TreatmentPlanStatus.draft,
          createdAt: DateTime.now(),
        );
        await ref.read(prontuarioRepositoryProvider).saveTreatmentPlan(plan);
      } else {
        final plan = currentState.first;
        final updatedPlan = plan.copyWith(
          items: [...plan.items, item],
          updatedAt: DateTime.now(),
        );
        await ref.read(prontuarioRepositoryProvider).saveTreatmentPlan(updatedPlan);
      }
      return await ref.read(prontuarioRepositoryProvider).getTreatmentPlans(patientId);
    });
  }

  /// Salva ou atualiza um plano completo.
  Future<void> savePlan(TreatmentPlan plan) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(prontuarioRepositoryProvider).saveTreatmentPlan(plan);
      return await ref.read(prontuarioRepositoryProvider).getTreatmentPlans(patientId);
    });
  }
}

/// Provider para criar a instância do TreatmentPlanViewModel por paciente.
final treatmentPlanViewModelProvider = StateNotifierProvider.family<TreatmentPlanViewModel, AsyncValue<List<TreatmentPlan>>, String>((ref, patientId) {
  return TreatmentPlanViewModel(ref, patientId);
});
