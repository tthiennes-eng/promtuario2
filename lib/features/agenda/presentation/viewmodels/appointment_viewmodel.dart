import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/core/network/realtime_service.dart';

/// Estado do ViewModel de Agenda.
class AppointmentState {
  final AsyncValue<List<Appointment>> appointments;
  final DateTime selectedDate;
  final Clinic? selectedClinic;
  final List<Clinic> clinics;

  AppointmentState({
    required this.appointments,
    required this.selectedDate,
    this.selectedClinic,
    this.clinics = const [],
  });

  AppointmentState copyWith({
    AsyncValue<List<Appointment>>? appointments,
    DateTime? selectedDate,
    Clinic? selectedClinic,
    List<Clinic>? clinics,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedClinic: selectedClinic ?? this.selectedClinic,
      clinics: clinics ?? this.clinics,
    );
  }
}

/// Gerencia o estado da agenda de atendimentos organizada por clínica.
class AppointmentViewModel extends StateNotifier<AppointmentState> {
  AppointmentViewModel(this.ref)
      : super(AppointmentState(
          appointments: const AsyncValue.loading(),
          selectedDate: DateTime.now(),
        )) {
    _initRealtime();
    _loadInitialData();
  }

  final Ref ref;

  void _initRealtime() {
    final realtime = ref.read(realtimeServiceProvider);
    realtime.on('AppointmentUpdated', (args) {
      refresh();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final proceduresRepo = ref.read(proceduresRepositoryProvider);
      final clinics = await proceduresRepo.getClinics(onlyActive: true);
      
      state = state.copyWith(clinics: clinics);
      
      if (clinics.isNotEmpty) {
        selectClinic(clinics.first);
      } else {
        state = state.copyWith(appointments: const AsyncValue.data([]));
      }
    } catch (e, stack) {
      state = state.copyWith(appointments: AsyncValue.error(e, stack));
    }
  }

  Future<void> selectClinic(Clinic clinic) async {
    state = state.copyWith(selectedClinic: clinic, appointments: const AsyncValue.loading());
    await refresh();
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(selectedDate: date, appointments: const AsyncValue.loading());
    await refresh();
  }

  Future<void> refresh() async {
    if (state.selectedClinic == null) return;

    state = state.copyWith(appointments: const AsyncValue.loading());
    
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(appointmentRepositoryProvider);
      final date = state.selectedDate;
      final start = DateTime(date.year, date.month, date.day, 0, 0);
      final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

      return await repository.getAppointments(
        start: start,
        end: end,
        clinicId: state.selectedClinic!.id,
      );
    });

    state = state.copyWith(appointments: result);
  }

  /// Agenda um novo atendimento.
  Future<void> schedule(Appointment appointment) async {
    await AsyncValue.guard(() async {
      final repository = ref.read(appointmentRepositoryProvider);
      await repository.scheduleAppointment(appointment);
      await refresh();
    });
  }

  /// Atualiza o status (Confirmado, Faltou, Atendido, etc).
  Future<void> updateStatus(String id, AppointmentStatus status) async {
    await AsyncValue.guard(() async {
      final repository = ref.read(appointmentRepositoryProvider);
      await repository.updateAppointmentStatus(id, status);
      await refresh();
    });
  }
}

/// Provider para criar a instância do AppointmentViewModel.
final appointmentViewModelProvider = StateNotifierProvider<AppointmentViewModel, AppointmentState>((ref) {
  return AppointmentViewModel(ref);
});
