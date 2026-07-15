import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/repositories/i_prontuario_repository.dart';
import '../../../../core/providers/providers.dart';

part 'documents_viewmodel.g.dart';

@riverpod
class DocumentsViewModel extends _$DocumentsViewModel {
  @override
  FutureOr<List<Prescription>> build(String patientId) async {
    return _fetchHistory(patientId);
  }

  Future<List<Prescription>> _fetchHistory(String patientId) async {
    final repository = ref.read(prontuarioRepositoryProvider);
    return await repository.getPrescriptionHistory(patientId);
  }

  Future<void> emitPrescription(Prescription prescription) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(prontuarioRepositoryProvider);
      await repository.createPrescription(prescription);
      return _fetchHistory(prescription.patientId);
    });
  }

  Future<void> emitCertificate(MedicalCertificate certificate) async {
    final repository = ref.read(prontuarioRepositoryProvider);
    await repository.createCertificate(certificate);
  }
}
