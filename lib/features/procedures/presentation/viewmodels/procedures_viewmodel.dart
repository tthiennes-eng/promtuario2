import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/procedure.dart';
import '../../domain/repositories/i_procedure_repository.dart';
import '../../../../core/providers/providers.dart';

part 'procedures_viewmodel.g.dart';

@riverpod
class ProceduresViewModel extends _$ProceduresViewModel {
  @override
  FutureOr<List<Procedure>> build() async {
    return _fetchProcedures();
  }

  Future<List<Procedure>> _fetchProcedures() async {
    final repository = ref.read(procedureRepositoryProvider);
    return await repository.getProcedures();
  }

  Future<void> fetchBySpecialty(String specialty) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(procedureRepositoryProvider);
      return await repository.getProceduresBySpecialty(specialty);
    });
  }
}
