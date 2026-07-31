import '../entities/clinic.dart';
import '../entities/procedure.dart';

/// Contrato para o Repositório de Clínicas e Procedimentos.
abstract class IProceduresRepository {
  /// Recupera todas as clínicas da instituição.
  Future<List<Clinic>> getClinics({bool onlyActive = true});

  /// Salva ou atualiza uma clínica.
  Future<void> saveClinic(Clinic clinic);

  /// Sincroniza clínicas criadas ou editadas offline.
  Future<void> syncClinics();

  /// Recupera os procedimentos disponíveis para uma clínica específica.
  Future<List<Procedure>> getProceduresByClinic(String clinicId);

  /// Recupera todos os procedimentos disponíveis no sistema.
  Future<List<Procedure>> getAllProcedures();
}
