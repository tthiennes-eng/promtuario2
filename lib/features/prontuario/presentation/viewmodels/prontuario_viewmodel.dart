import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/features/prontuario/domain/entities/odontogram.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/prontuario_summary_provider.dart';

/// Gerencia o prontuário eletrônico com suporte a faces de dentes independentes.
class ProntuarioViewModel extends StateNotifier<AsyncValue<Odontogram?>> {
  final Ref ref;
  final String patientId;

  ProntuarioViewModel(this.ref, this.patientId) : super(const AsyncValue.loading()) {
    _fetchOdontogram();
  }

  Future<void> _fetchOdontogram() async {
    state = await AsyncValue.guard(() => 
      ref.read(prontuarioRepositoryProvider).getOdontogram(patientId)
    );
  }

  Future<void> refresh() async => _fetchOdontogram();

  /// Atualiza a condição das faces especificadas preservando as demais condições do dente.
  Future<void> updateToothCondition(ToothCondition newCondition) async {
    final current = state.value;
    if (current == null || newCondition.surfaces.isEmpty) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final List<ToothCondition> updatedTeeth = List.from(current.teeth);
      final surfacesToUpdate = newCondition.surfaces.toSet();

      // 1. Remove as faces atualizadas de qualquer registro existente deste dente
      for (int i = 0; i < updatedTeeth.length; i++) {
        if (updatedTeeth[i].toothNumber == newCondition.toothNumber) {
          final remaining = updatedTeeth[i]
              .surfaces
              .where((s) => !surfacesToUpdate.contains(s))
              .toList();
          if (remaining.length != updatedTeeth[i].surfaces.length) {
            if (remaining.isEmpty) {
              updatedTeeth.removeAt(i);
              i--;
            } else {
              updatedTeeth[i] = updatedTeeth[i].copyWith(surfaces: remaining);
            }
          }
        }
      }

      // 2. Adiciona a nova condição se não for "Hígido"
      if (newCondition.condition != ConditionType.healthy) {
        updatedTeeth.add(newCondition);
      }

      final updated = current.copyWith(
        teeth: updatedTeeth,
        updatedAt: DateTime.now(),
      );

      await ref.read(prontuarioRepositoryProvider).saveOdontogram(updated);
      ref.invalidate(prontuarioSummaryProvider(patientId));
      ref.invalidate(clinicalTimelineProvider(patientId));
      return updated;
    });
  }
}

final prontuarioViewModelProvider = StateNotifierProvider.family<ProntuarioViewModel, AsyncValue<Odontogram?>, String>((ref, patientId) {
  return ProntuarioViewModel(ref, patientId);
});
