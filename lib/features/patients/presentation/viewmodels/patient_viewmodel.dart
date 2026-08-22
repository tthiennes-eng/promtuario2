import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/patients/domain/entities/patient.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/core/network/realtime_service.dart';

/// Estado que combina a lista de pacientes com o histórico global de agendamentos.
class PatientListState {
  final AsyncValue<List<Patient>> patients;
  final AsyncValue<List<Appointment>> allHistory;

  PatientListState({
    required this.patients,
    required this.allHistory,
  });
}

/// Provider que busca todos os agendamentos do sistema para alimentar os prontuários na lista.
final allAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  // Busca histórico amplo para garantir que todos os atendimentos apareçam
  return await repository.getAppointments(
    start: DateTime(2000), 
    end: DateTime(2100),
  );
});

/// Notifier para gerenciar a lógica de pacientes.
class PatientViewModel extends StateNotifier<AsyncValue<List<Patient>>> {
  PatientViewModel(this.ref) : super(const AsyncValue.loading()) {
    _initRealtime();
    refresh();
  }

  final Ref ref;

  /// Assina os eventos do SignalR para atualizar a lista automaticamente
  /// quando outro computador da rede cadastrar ou editar um paciente,
  /// sem precisar esperar o ciclo de sincronização periódica (10s) ou
  /// que o usuário reabra a tela manualmente.
  void _initRealtime() {
    final realtime = ref.read(realtimeServiceProvider);
    realtime.on('PatientCreated', (args) => refresh());
    realtime.on('PatientUpdated', (args) => refresh());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final repository = ref.read(patientRepositoryProvider);
    state = await AsyncValue.guard(() => repository.getPatients());
  }

  Future<void> searchPatients(String query) async {
    final repository = ref.read(patientRepositoryProvider);
    state = await AsyncValue.guard(() => repository.getPatients(query: query));
  }

  Future<void> addPatient(Patient patient) async {
    final repository = ref.read(patientRepositoryProvider);
    await repository.createPatient(patient);
    await refresh();
  }

  /// Atualiza um paciente já cadastrado. Antes desta correção, edições
  /// não eram enviadas ao servidor (updatePatient era um método vazio),
  /// então nunca chegavam aos outros computadores da rede.
  Future<void> editPatient(Patient patient) async {
    final repository = ref.read(patientRepositoryProvider);
    await repository.updatePatient(patient);
    await refresh();
  }
}

final patientViewModelProvider = StateNotifierProvider<PatientViewModel, AsyncValue<List<Patient>>>((ref) {
  return PatientViewModel(ref);
});

/// Provider combinado que une Pacientes e Agendamentos de forma reativa.
/// Sempre que um agendamento for feito, este provider atualizará a lista automaticamente.
final patientListWithHistoryProvider = Provider<PatientListState>((ref) {
  final patients = ref.watch(patientViewModelProvider);
  final history = ref.watch(allAppointmentsProvider);

  return PatientListState(
    patients: patients,
    allHistory: history,
  );
});
