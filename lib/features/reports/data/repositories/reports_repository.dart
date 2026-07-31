import '../../../../core/network/api_client.dart';
import '../../domain/entities/report_data.dart';
import '../../domain/repositories/i_reports_repository.dart';

/// Implementação do repositório de relatórios com suporte a filtros por clínica.
class ReportsRepository implements IReportsRepository {
  final ApiClient _apiClient;

  ReportsRepository(this._apiClient);

  @override
  Future<List<SpecialtyProduction>> getProductionBySpecialty({
    required DateTime start,
    required DateTime end,
    String? clinicId,
  }) async {
    final response = await _apiClient.instance.get('/reports/production', queryParameters: {
      'startDate': start.toIso8601String(),
      'endDate': end.toIso8601String(),
      if (clinicId != null) 'clinicId': clinicId,
    });

    final List<dynamic> data = response.data;
    return data.map((json) => SpecialtyProduction.fromJson(json)).toList();
  }

  @override
  Future<ClinicPerformanceMetrics> getClinicMetrics({
    required DateTime start,
    required DateTime end,
    String? clinicId,
  }) async {
    final response = await _apiClient.instance.get('/reports/metrics', queryParameters: {
      'startDate': start.toIso8601String(),
      'endDate': end.toIso8601String(),
      if (clinicId != null) 'clinicId': clinicId,
    });

    return ClinicPerformanceMetrics.fromJson(response.data);
  }
}
