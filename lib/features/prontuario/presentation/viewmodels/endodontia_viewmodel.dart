import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/prontuario_summary_provider.dart';

class EndodontiaViewModel extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Ref ref;
  final String patientId;

  EndodontiaViewModel(this.ref, this.patientId) : super(const AsyncValue.loading()) {
    load();
  }

  static const _sheetPrefixes = [
    'anamnese_',
    'extraoral_',
    'intraoral_',
    'odontopediatria_',
    'endodontia_',
    'ppr_',
    'dtm_',
    'tcle_',
  ];

  String get _basePatientId {
    for (final prefix in _sheetPrefixes) {
      if (patientId.startsWith(prefix)) {
        return patientId.substring(prefix.length);
      }
    }
    return patientId;
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
      ref.read(prontuarioRepositoryProvider).getEndodontia(patientId)
    );
  }

  Future<void> save(Map<String, dynamic> data) async {
    await ref.read(prontuarioRepositoryProvider).saveEndodontia(patientId, data);
    state = AsyncValue.data(data);
    final baseId = _basePatientId;
    ref.invalidate(prontuarioSummaryProvider(baseId));
    ref.invalidate(clinicalTimelineProvider(baseId));
  }
}

final endodontiaViewModelProvider = StateNotifierProvider.family<EndodontiaViewModel, AsyncValue<Map<String, dynamic>?>, String>((ref, patientId) {
  return EndodontiaViewModel(ref, patientId);
});
