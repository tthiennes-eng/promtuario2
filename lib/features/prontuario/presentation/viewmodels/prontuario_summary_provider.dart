import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/core/providers/providers.dart';

final prontuarioSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, patientId) async {
  return ref.read(prontuarioRepositoryProvider).getProntuarioSummary(patientId);
});

final clinicalTimelineProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, patientId) async {
  return ref.read(prontuarioRepositoryProvider).getClinicalTimeline(patientId);
});

final clinicalSheetHistoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, ({String patientId, String sheetType})>(
        (ref, params) async {
  return ref
      .read(prontuarioRepositoryProvider)
      .getClinicalSheetHistory(params.patientId, params.sheetType);
});
