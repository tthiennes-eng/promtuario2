import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/prontuario/domain/entities/prescription.dart';
import 'package:promt/core/providers/providers.dart';

/// Gerencia documentos (atestados/receitas) com sincronização imediata após salvamento.
class DocumentsViewModel extends StateNotifier<AsyncValue<List<dynamic>>> {
  DocumentsViewModel(this.ref, this.patientId) : super(const AsyncValue.loading()) {
    _fetchDocuments();
  }
  
  final Ref ref;
  final String patientId;
  
  Future<void> _fetchDocuments() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(prontuarioRepositoryProvider);
      final prescriptions = await repo.getPrescriptionHistory(patientId);
      final certificates = await repo.getCertificateHistory(patientId);
      return [...prescriptions, ...certificates];
    });
  }

  Future<void> refresh() async => _fetchDocuments();

  Future<void> emitPrescription(Prescription prescription) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await ref.read(prontuarioRepositoryProvider).createPrescription(prescription);
      return _fetchDocumentsInternal();
    });
    state = result;
    if (result is AsyncError) throw result.error!;
  }

  Future<void> emitCertificate(MedicalCertificate certificate) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await ref.read(prontuarioRepositoryProvider).createCertificate(certificate);
      return _fetchDocumentsInternal();
    });
    state = result;
    if (result is AsyncError) throw result.error!;
  }

  Future<List<dynamic>> _fetchDocumentsInternal() async {
    final repo = ref.read(prontuarioRepositoryProvider);
    final p = await repo.getPrescriptionHistory(patientId);
    final c = await repo.getCertificateHistory(patientId);
    return [...p, ...c];
  }
}

final documentsViewModelProvider = StateNotifierProvider.family<DocumentsViewModel, AsyncValue<List<dynamic>>, String>((ref, patientId) {
  return DocumentsViewModel(ref, patientId);
});
