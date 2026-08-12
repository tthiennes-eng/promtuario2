import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/patients/domain/entities/patient.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/core/providers/providers.dart';

class PatientListState {
  final AsyncValue<List<Patient>> patients;
  final List<Appointment> allHistory;

  PatientListState({
    required this.patients,
    this.allHistory = const [],
  });

  PatientListState copyWith({
    AsyncValue<List<Patient>>? patients,
    List<Appointment>? allHistory,
  }) {
    return PatientListState(
      patients: patients ?? this.patients,
      allHistory: allHistory ?? this.allHistory,
    );
  }
}

class PatientViewModel extends StateNotifier<PatientListState> {
  PatientViewModel(this.ref) : super(PatientListState(patients: const AsyncValue.loading())) {
    refresh();
  }

  final Ref ref;

  Future<void> refresh() async {
    state = state.copyWith(patients: const AsyncValue.loading());
    
    final repository = ref.read(patientRepositoryProvider);
    final appointmentRepo = ref.read(appointmentRepositoryProvider);

    final patientsResult = await AsyncValue.guard(() => repository.getPatients());
    
    // Busca TODOS os agendamentos locais para compor o histórico na lista
    final history = await appointmentRepo.getAppointments(
      start: DateTime(2000), 
      end: DateTime(2100)
    );

    state = PatientListState(
      patients: patientsResult,
      allHistory: history,
    );
  }

  Future<void> searchPatients(String query) async {
    final repository = ref.read(patientRepositoryProvider);
    final results = await AsyncValue.guard(() => repository.getPatients(query: query));
    state = state.copyWith(patients: results);
  }

  Future<void> addPatient(Patient patient) async {
    final repository = ref.read(patientRepositoryProvider);
    await repository.createPatient(patient);
    await refresh();
  }
}

final patientViewModelProvider = StateNotifierProvider<PatientViewModel, PatientListState>((ref) {
  return PatientViewModel(ref);
});
