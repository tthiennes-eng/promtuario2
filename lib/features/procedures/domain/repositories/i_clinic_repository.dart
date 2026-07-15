import '../entities/clinic.dart';

/// Contrato para o Repositório de Clínicas/Especialidades.
abstract class IClinicRepository {
  /// Lista todas as clínicas ativas na universidade.
  Future<List<Clinic>> getClinics();
}
