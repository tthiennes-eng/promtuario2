import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/i_appointment_repository.dart';
import '../../../core/providers/providers.dart';

part 'appointment_viewmodel.g.dart';

@riverpod
class AppointmentViewModel extends _$AppointmentViewModel {
  @override
  FutureOr<List<Appointment>> build() async {
    // Inicializa buscando os agendamentos do dia atual
    return _fetchDailyAppointments(DateTime.now());
  }

  Future<List<Appointment>> _fetchDailyAppointments(DateTime date) async {
    final repository = ref.read(appointmentRepositoryProvider);
    final start = DateTime(date.year, date.month, date.day, 0, 0);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return await repository.getAppointments(start: start, end: end);
  }

  /// Busca agendamentos para uma data específica.
  Future<void> fetchByDate(DateTime date) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDailyAppointments(date));
  }

  /// Cria um novo agendamento.
  Future<void> schedule(Appointment appointment) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(appointmentRepositoryProvider);
      await repository.scheduleAppointment(appointment);
      return _fetchDailyAppointments(appointment.startTime);
    });
  }

  /// Atualiza o status de um agendamento.
  Future<void> updateStatus(String id, AppointmentStatus status, DateTime date) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(appointmentRepositoryProvider);
      await repository.updateAppointmentStatus(id, status);
      return _fetchDailyAppointments(date);
    });
  }
}
