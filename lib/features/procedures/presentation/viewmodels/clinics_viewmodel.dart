import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/clinic.dart';
import '../../domain/repositories/i_clinic_repository.dart';
import '../../../../core/providers/providers.dart';

part 'clinics_viewmodel.g.dart';

@riverpod
class ClinicsViewModel extends _$ClinicsViewModel {
  @override
  FutureOr<List<Clinic>> build() async {
    return _fetchClinics();
  }

  Future<List<Clinic>> _fetchClinics() async {
    final repository = ref.read(clinicRepositoryProvider);
    return await repository.getClinics();
  }
}
