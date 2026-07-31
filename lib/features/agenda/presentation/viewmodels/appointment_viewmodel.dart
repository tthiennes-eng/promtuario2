import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/core/network/realtime_service.dart';

enum DayPeriod { all, morning, afternoon, night }

/// Representa um slot na agenda (pode ser um agendamento ou horário livre)
class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final Appointment? appointment;
  final bool isFree;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    this.appointment,
    this.isFree = false,
  });
}

/// Estado do ViewModel de Agenda com Filtros Avançados e Slots.
class AppointmentState {
  final AsyncValue<List<Appointment>> appointments;
  final AsyncValue<List<Appointment>> institutionalAppointments; // Para visão de todas as clínicas
  final DateTime selectedDate;
  final Clinic? selectedClinic;
  final List<Clinic> clinics;
  
  // Filtros
  final DayPeriod period;
  final String? filterStudent;
  final String? filterProfessor;
  final String? filterProcedure;
  final AppointmentStatus? filterStatus;

  AppointmentState({
    required this.appointments,
    this.institutionalAppointments = const AsyncValue.data([]),
    required this.selectedDate,
    this.selectedClinic,
    this.clinics = const [],
    this.period = DayPeriod.all,
    this.filterStudent,
    this.filterProfessor,
    this.filterProcedure,
    this.filterStatus,
  });

  List<Appointment> get filteredAppointments {
    return appointments.maybeWhen(
      data: (list) {
        return list.where((app) {
          // Filtro por Período
          if (period != DayPeriod.all) {
            final hour = app.startTime.hour;
            if (period == DayPeriod.morning && (hour < 7 || hour >= 12)) return false;
            if (period == DayPeriod.afternoon && (hour < 12 || hour >= 18)) return false;
            if (period == DayPeriod.night && hour < 18) return false;
          }
          // Filtro por Aluno
          if (filterStudent != null && !(app.studentName?.toLowerCase().contains(filterStudent!.toLowerCase()) ?? false)) return false;
          // Filtro por Professor
          if (filterProfessor != null && !(app.professorName?.toLowerCase().contains(filterProfessor!.toLowerCase()) ?? false)) return false;
          // Filtro por Procedimento
          if (filterProcedure != null && !(app.procedureName?.toLowerCase().contains(filterProcedure!.toLowerCase()) ?? false)) return false;
          // Filtro por Status
          if (filterStatus != null && app.status != filterStatus) return false;
          
          return true;
        }).toList();
      },
      orElse: () => [],
    );
  }

  /// Gera a lista de slots para a clínica e data selecionadas
  List<TimeSlot> get timeSlots {
    if (selectedClinic == null) return [];
    
    final allSlots = <TimeSlot>[];
    final date = selectedDate;
    final startHour = selectedClinic!.startHour;
    final endHour = selectedClinic!.endHour;
    final duration = selectedClinic!.slotDurationMinutes;
    
    final dayAppointments = appointments.value ?? [];

    for (int hour = startHour; hour < endHour; hour++) {
      for (int min = 0; min < 60; min += duration) {
        final slotStart = DateTime(date.year, date.month, date.day, hour, min);
        final slotEnd = slotStart.add(Duration(minutes: duration));
        
        // Verifica se há agendamentos neste slot (considerando capacidade da clínica futuramente se necessário)
        // Por enquanto, mostra agendamentos existentes ou slot livre
        final appsInSlot = dayAppointments.where((a) => 
          (a.startTime.isAtSameMomentAs(slotStart)) || 
          (a.startTime.isAfter(slotStart) && a.startTime.isBefore(slotEnd))
        ).toList();

        if (appsInSlot.isEmpty) {
          allSlots.add(TimeSlot(startTime: slotStart, endTime: slotEnd, isFree: true));
        } else {
          for (final app in appsInSlot) {
            allSlots.add(TimeSlot(startTime: slotStart, endTime: slotEnd, appointment: app));
          }
        }
      }
    }
    return allSlots;
  }

  AppointmentState copyWith({
    AsyncValue<List<Appointment>>? appointments,
    AsyncValue<List<Appointment>>? institutionalAppointments,
    DateTime? selectedDate,
    Clinic? selectedClinic,
    List<Clinic>? clinics,
    DayPeriod? period,
    String? filterStudent,
    String? filterProfessor,
    String? filterProcedure,
    AppointmentStatus? filterStatus,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      institutionalAppointments: institutionalAppointments ?? this.institutionalAppointments,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedClinic: selectedClinic ?? this.selectedClinic,
      clinics: clinics ?? this.clinics,
      period: period ?? this.period,
      filterStudent: filterStudent ?? this.filterStudent,
      filterProfessor: filterProfessor ?? this.filterProfessor,
      filterProcedure: filterProcedure ?? this.filterProcedure,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}

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
    realtime.on('AppointmentUpdated', (args) => refresh());
  }

  Future<void> _loadInitialData() async {
    try {
      final proceduresRepo = ref.read(proceduresRepositoryProvider);
      final clinics = await proceduresRepo.getClinics(onlyActive: true);
      state = state.copyWith(clinics: clinics);
      if (clinics.isNotEmpty) selectClinic(clinics.first);
    } catch (e, stack) {
      state = state.copyWith(appointments: AsyncValue.error(e, stack));
    }
  }

  void setFilters({
    DayPeriod? period,
    String? student,
    String? professor,
    String? procedure,
    AppointmentStatus? status,
  }) {
    state = state.copyWith(
      period: period,
      filterStudent: student,
      filterProfessor: professor,
      filterProcedure: procedure,
      filterStatus: status,
    );
  }

  void clearFilters() {
    state = state.copyWith(
      period: DayPeriod.all,
      filterStudent: null,
      filterProfessor: null,
      filterProcedure: null,
      filterStatus: null,
    );
  }

  Future<void> selectClinic(Clinic clinic) async {
    state = state.copyWith(selectedClinic: clinic);
    await refresh();
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
    await refresh();
  }

  Future<void> refresh() async {
    if (state.selectedClinic == null) return;
    
    state = state.copyWith(appointments: const AsyncValue.loading());
    
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(appointmentRepositoryProvider);
      final date = state.selectedDate;
      return await repository.getAppointments(
        start: DateTime(date.year, date.month, date.day, 0, 0),
        end: DateTime(date.year, date.month, date.day, 23, 59, 59),
        clinicId: state.selectedClinic!.id,
      );
    });
    
    state = state.copyWith(appointments: result);
  }

  /// Busca agendamentos de todas as clínicas para a visão institucional
  Future<void> fetchInstitutionalData() async {
    state = state.copyWith(institutionalAppointments: const AsyncValue.loading());
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(appointmentRepositoryProvider);
      final date = state.selectedDate;
      return await repository.getAppointments(
        start: DateTime(date.year, date.month, date.day, 0, 0),
        end: DateTime(date.year, date.month, date.day, 23, 59, 59),
        clinicId: null, // Busca todos
      );
    });
    state = state.copyWith(institutionalAppointments: result);
  }

  Future<void> schedule(Appointment appointment) async {
    await ref.read(appointmentRepositoryProvider).scheduleAppointment(appointment);
    await refresh();
  }

  Future<void> updateStatus(String id, AppointmentStatus status) async {
    await ref.read(appointmentRepositoryProvider).updateAppointmentStatus(id, status);
    await refresh();
  }

  Map<String, dynamic> getDayStats() {
    final list = state.appointments.value ?? [];
    return {
      'total': list.length,
      'completed': list.where((a) => a.status == AppointmentStatus.completed).length,
      'missed': list.where((a) => a.status == AppointmentStatus.missed).length,
      'canceled': list.where((a) => a.status == AppointmentStatus.cancelled).length,
      'occupancy': state.selectedClinic != null && state.selectedClinic!.capacity > 0 
          ? (list.length / (state.selectedClinic!.capacity * 10))
          : 0.0,
    };
  }
}

final appointmentViewModelProvider = StateNotifierProvider<AppointmentViewModel, AppointmentState>((ref) {
  return AppointmentViewModel(ref);
});
