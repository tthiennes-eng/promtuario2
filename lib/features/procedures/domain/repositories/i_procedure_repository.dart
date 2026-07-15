import '../entities/procedure.dart';

/// Contrato para o Repositório de Procedimentos.
abstract class IProcedureRepository {
  /// Recupera o catálogo completo de procedimentos.
  Future<List<Procedure>> getProcedures();

  /// Recupera procedimentos por especialidade.
  Future<List<Procedure>> getProceduresBySpecialty(String specialty);
}
