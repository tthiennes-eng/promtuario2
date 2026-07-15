import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/repositories/i_audit_repository.dart';
import '../../../../core/providers/providers.dart';

part 'audit_viewmodel.g.dart';

/// Notifier responsável por gerenciar o estado dos logs de auditoria.
/// Garante que os registros de acesso (LGPD) sejam carregados e exibidos corretamente.
@riverpod
class AuditViewModel extends _$AuditViewModel {
  @override
  FutureOr<List<AuditLog>> build() async {
    return _fetchLogs();
  }

  /// Recupera os logs da API através do repositório.
  Future<List<AuditLog>> _fetchLogs({int page = 1, String? userId}) async {
    final repository = ref.read(auditRepositoryProvider);
    return await repository.getLogs(page: page, userId: userId);
  }

  /// Atualiza a lista de logs.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLogs());
  }
}
