import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/features/prontuario/domain/entities/odontogram.dart';

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

  /// Atualiza a condição de uma face específica preservando as demais condições do dente.
  Future<void> updateToothCondition(ToothCondition newCondition) async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      List<ToothCondition> updatedTeeth = List.from(current.teeth);
      
      // 1. Remove a face atual de qualquer registro existente deste dente
      final surfaceToUpdate = newCondition.surfaces.first;
      
      for (int i = 0; i < updatedTeeth.length; i++) {
        if (updatedTeeth[i].toothNumber == newCondition.toothNumber) {
          // Se o registro contém a face que estamos editando, removemos essa face dele
          if (updatedTeeth[i].surfaces.contains(surfaceToUpdate)) {
            final newSurfaces = updatedTeeth[i].surfaces.where((s) => s != surfaceToUpdate).toList();
            if (newSurfaces.isEmpty) {
              updatedTeeth.removeAt(i);
              i--;
            } else {
              updatedTeeth[i] = updatedTeeth[i].copyWith(surfaces: newSurfaces);
            }
          }
        }
      }

      // 2. Adiciona a nova condição se não for "Saudável"
      if (newCondition.condition != ConditionType.healthy) {
        updatedTeeth.add(newCondition);
      }

      final updated = current.copyWith(
        teeth: updatedTeeth,
        updatedAt: DateTime.now(),
      );

      await ref.read(prontuarioRepositoryProvider).saveOdontogram(updated);
      return updated;
    });
  }
}

final prontuarioViewModelProvider = StateNotifierProvider.family<ProntuarioViewModel, AsyncValue<Odontogram?>, String>((ref, patientId) {
  return ProntuarioViewModel(ref, patientId);
});
