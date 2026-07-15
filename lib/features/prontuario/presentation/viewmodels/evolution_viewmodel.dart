import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/evolution.dart';
import '../../domain/repositories/i_prontuario_repository.dart';
import '../../../../core/providers/providers.dart';

part 'evolution_viewmodel.g.dart';

@riverpod
class EvolutionViewModel extends _$EvolutionViewModel {
  @override
  FutureOr<List<Evolution>> build(String patientId) async {
    return _fetchHistory(patientId);
  }

  Future<List<Evolution>> _fetchHistory(String patientId) async {
    final repository = ref.read(prontuarioRepositoryProvider);
    final history = await repository.getEvolutionHistory(patientId);
    return history.map((json) => Evolution.fromJson(json)).toList();
  }

  Future<void> addEvolution(String description, String professorId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(prontuarioRepositoryProvider);
      await repository.addEvolution(arg, description, professorId);
      return _fetchHistory(arg);
    });
  }
}
