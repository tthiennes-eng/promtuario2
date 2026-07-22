import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/prontuario/domain/entities/treatment_plan.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:uuid/uuid.dart';

/// Gerencia a lógica de negócio dos planos de tratamento de um paciente.
class TreatmentPlanViewModel extends StateNotifier<AsyncValue<List<TreatmentPlan>>> {
  final Ref _ref;
  final String _patientId;

  TreatmentPlanViewModel(this._ref, this._patientId) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = await AsyncValue.guard(() => 
      _ref.read(prontuarioRepositoryProvider).getTreatmentPlans(_patientId)
    );
  }

  Future<void> refresh() async => _init();

  /// Adiciona um item ao plano atual ou cria um novo se necessário.
  Future<void> addItem(TreatmentItem item) async {
    final currentState = state.value ?? [];
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final repo = _ref.read(prontuarioRepositoryProvider);
      
      if (currentState.isEmpty) {
        final authState = _ref.read(authViewModelProvider);
        final plan = TreatmentPlan(
          id: const Uuid().v4(),
          patientId: _patientId,
          description: 'Plano de tratamento',
          items: [item],
          createdByUserId: authState.user?.id ?? 'system',
          status: TreatmentPlanStatus.draft,
          createdAt: DateTime.now(),
        );
        await repo.saveTreatmentPlan(plan);
      } else {
        final plan = currentState.first;
        final updatedPlan = plan.copyWith(
          items: [...plan.items, item],
          updatedAt: DateTime.now(),
        );
        await repo.saveTreatmentPlan(updatedPlan);
      }
      return repo.getTreatmentPlans(_patientId);
    });
  }

  /// Salva ou atualiza um plano de tratamento completo.
  Future<void> savePlan(TreatmentPlan plan) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ref.read(prontuarioRepositoryProvider).saveTreatmentPlan(plan);
      return _ref.read(prontuarioRepositoryProvider).getTreatmentPlans(_patientId);
    });
  }
}

/// Provider especializado para o prontuário.
final treatmentPlanViewModelProvider = StateNotifierProvider.family<TreatmentPlanViewModel, AsyncValue<List<TreatmentPlan>>, String>((ref, patientId) {
  return TreatmentPlanViewModel(ref, patientId);
});
