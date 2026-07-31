import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/reports/domain/entities/report_data.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/core/providers/providers.dart';

/// Estado do ViewModel de Relatórios.
class ReportsState {
  final AsyncValue<ClinicPerformanceMetrics?> metrics;
  final DateTime startDate;
  final DateTime endDate;
  final Clinic? selectedClinic;
  final List<Clinic> clinics;

  ReportsState({
    required this.metrics,
    required this.startDate,
    required this.endDate,
    this.selectedClinic,
    this.clinics = const [],
  });

  ReportsState copyWith({
    AsyncValue<ClinicPerformanceMetrics?>? metrics,
    DateTime? startDate,
    DateTime? endDate,
    Clinic? selectedClinic,
    List<Clinic>? clinics,
  }) {
    return ReportsState(
      metrics: metrics ?? this.metrics,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedClinic: selectedClinic ?? this.selectedClinic,
      clinics: clinics ?? this.clinics,
    );
  }
}

/// Gerencia relatórios e estatísticas filtrados por clínica e período.
class ReportsViewModel extends StateNotifier<ReportsState> {
  ReportsViewModel(this.ref)
      : super(ReportsState(
          metrics: const AsyncValue.loading(),
          startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
          endDate: DateTime.now(),
        )) {
    _init();
  }

  final Ref ref;

  Future<void> _init() async {
    final proceduresRepo = ref.read(proceduresRepositoryProvider);
    final clinics = await proceduresRepo.getClinics(onlyActive: false);
    state = state.copyWith(clinics: clinics);
    await refresh();
  }

  Future<void> selectClinic(Clinic? clinic) async {
    state = state.copyWith(selectedClinic: clinic);
    await refresh();
  }

  Future<void> setPeriod(DateTime start, DateTime end) async {
    state = state.copyWith(startDate: start, endDate: end);
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(metrics: const AsyncValue.loading());
    final result = await AsyncValue.guard(() async {
      final repo = ref.read(reportsRepositoryProvider);
      return await repo.getClinicMetrics(
        start: state.startDate,
        end: state.endDate,
        clinicId: state.selectedClinic?.id,
      );
    });
    state = state.copyWith(metrics: result);
  }
}

final reportsViewModelProvider = StateNotifierProvider<ReportsViewModel, ReportsState>((ref) {
  return ReportsViewModel(ref);
});
