import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/core/network/realtime_service.dart';

/// Gerencia o estado da agenda de atendimentos.
class AppointmentViewModel extends StateNotifier<AsyncValue<List<Appointment>>> {
  AppointmentViewModel(this.ref) : super(const AsyncValue.loading()) {
    _initRealtime();
    _init();
  }

  final Ref ref;
  DateTime _currentDate = DateTime.now();

  void _initRealtime() {
    final realtime = ref.read(realtimeServiceProvider);
    realtime.on('AppointmentUpdated', (args) {
      refresh();
    });
  }

  Future<void> _init() async {
    state = await AsyncValue.guard(() => _fetchDailyAppointments(_currentDate));
  }

  Future<List<Appointment>> _fetchDailyAppointments(DateTime date) async {
    _currentDate = date;
    final repository = ref.read(appointmentRepositoryProvider);
    final start = DateTime(date.year, date.month, date.day, 0, 0);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await repository.getAppointments(start: start, end: end);
  }

  /// Navega para uma data específica e recarrega a agenda.
  Future<void> fetchByDate(DateTime date) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDailyAppointments(date));
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _fetchDailyAppointments(_currentDate));
  }

  /// Agenda um novo atendimento.
  Future<void> schedule(Appointment appointment) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(appointmentRepositoryProvider);
      await repository.scheduleAppointment(appointment);
      return _fetchDailyAppointments(appointment.startTime);
    });
  }

  /// Atualiza o status (Confirmado, Faltou, Atendido, etc).
  Future<void> updateStatus(String id, AppointmentStatus status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(appointmentRepositoryProvider);
      await repository.updateAppointmentStatus(id, status);
      return _fetchDailyAppointments(_currentDate);
    });
  }
}

/// Provider para criar a instância do AppointmentViewModel.
final appointmentViewModelProvider = StateNotifierProvider<AppointmentViewModel, AsyncValue<List<Appointment>>>((ref) {
  return AppointmentViewModel(ref);
});
