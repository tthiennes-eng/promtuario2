import '../entities/wait_list_entry.dart';

/// Contrato para o Repositório de Lista de Espera.
abstract class IWaitListRepository {
  /// Recupera as entradas ativas na lista de espera de uma clínica.
  Future<List<WaitListEntry>> getWaitListByClinic(String clinicId);

  /// Adiciona um paciente à lista de espera.
  Future<void> addToWaitList(WaitListEntry entry);

  /// Resolve uma entrada (marcar como agendado).
  Future<void> resolveEntry(String entryId);
}
