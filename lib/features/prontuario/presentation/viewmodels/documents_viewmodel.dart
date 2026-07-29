import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/prontuario/domain/entities/prescription.dart';
import 'package:promt/core/providers/providers.dart';

/// Gerencia documentos (atestados/receitas) gerados para o paciente.
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
      // Aqui poderíamos buscar atestados também e unir as listas
      return [...prescriptions];
    });
  }

  Future<void> refresh() async => _fetchDocuments();

  /// Emite uma nova receita médica/odontológica.
  Future<void> emitPrescription(Prescription prescription) async {
    final previousState = state;
    state = const AsyncValue.loading();
    
    final result = await AsyncValue.guard(() async {
      await ref.read(prontuarioRepositoryProvider).createPrescription(prescription);
      return _fetchDocumentsInternal();
    });

    if (result is AsyncError) {
      state = previousState; // Mantém dados anteriores em caso de erro
      throw result.error!; // Lança para o UI tratar
    } else {
      state = result;
    }
  }

  Future<List<dynamic>> _fetchDocumentsInternal() async {
    return await ref.read(prontuarioRepositoryProvider).getPrescriptionHistory(patientId);
  }

  /// Emite um novo atestado médico/odontológico.
  Future<void> emitCertificate(MedicalCertificate certificate) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(prontuarioRepositoryProvider).createCertificate(certificate);
      return _fetchDocumentsInternal();
    });
  }
}

final documentsViewModelProvider = StateNotifierProvider.family<DocumentsViewModel, AsyncValue<List<dynamic>>, String>((ref, patientId) {
  return DocumentsViewModel(ref, patientId);
});
