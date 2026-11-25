import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/core/network/realtime_service.dart';
import 'package:promt/features/patients/presentation/viewmodels/patient_viewmodel.dart';
import 'package:promt/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:uuid/uuid.dart';

enum AgendaDayPeriod { all, morning, afternoon, night }

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

class AppointmentState {
  final AsyncValue<List<Appointment>> appointments;
  final AsyncValue<List<Appointment>> institutionalAppointments;
  final DateTime selectedDate;
  final Clinic? selectedClinic;
  final List<Clinic> clinics;

  final AgendaDayPeriod period;
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
    this.period = AgendaDayPeriod.all,
    this.filterStudent,
    this.filterProfessor,
    this.filterProcedure,
    this.filterStatus,
  });

  List<Appointment> get filteredAppointments {
    return appointments.maybeWhen(
      data: (list) {
        return list.where((app) {
          if (period != AgendaDayPeriod.all) {
            final hour = app.startTime.hour;
            if (period == AgendaDayPeriod.morning && (hour < 7 || hour >= 12)) return false;
            if (period == AgendaDayPeriod.afternoon && (hour < 12 || hour >= 18)) return false;
            if (period == AgendaDayPeriod.night && hour < 18) return false;
          }

          final student = app.studentName?.toLowerCase() ?? app.doctorName.toLowerCase();
          final professor = app.professorName?.toLowerCase() ?? "";

          if (filterStudent != null && !student.contains(filterStudent!.toLowerCase())) return false;
          if (filterProfessor != null && !professor.contains(filterProfessor!.toLowerCase())) return false;
          if (filterProcedure != null && !(app.procedureName?.toLowerCase().contains(filterProcedure!.toLowerCase()) ?? false)) return false;
          if (filterStatus != null && app.status != filterStatus) return false;

          return true;
        }).toList();
      },
      orElse: () => [],
    );
  }

  List<TimeSlot> get timeSlots {
    if (selectedClinic == null) return [];

    final allSlots = <TimeSlot>[];
    final date = selectedDate;
    final startHour = selectedClinic!.startHour;
    final endHour = selectedClinic!.endHour;
    final duration = selectedClinic!.slotDurationMinutes > 0 ? selectedClinic!.slotDurationMinutes : 60;

    final dayAppointments = appointments.value ?? [];

    for (int hour = startHour; hour < endHour; hour++) {
      if (hour == 12 || hour == 13) continue; // Almoço

      for (int min = 0; min < 60; min += duration) {
        final slotStart = DateTime(date.year, date.month, date.day, hour, min);
        final slotEnd = slotStart.add(Duration(minutes: duration));

        final appsInSlot = dayAppointments.where((a) {
          final startTime = a.startTime.isUtc ? a.startTime.toLocal() : a.startTime;
          return startTime.isAtSameMomentAs(slotStart) || (startTime.isAfter(slotStart) && startTime.isBefore(slotEnd));
        }).toList();

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
    bool clearClinic = false,
    List<Clinic>? clinics,
    AgendaDayPeriod? period,
    String? filterStudent,
    String? filterProfessor,
    String? filterProcedure,
    AppointmentStatus? filterStatus,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      institutionalAppointments: institutionalAppointments ?? this.institutionalAppointments,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedClinic: clearClinic ? null : (selectedClinic ?? this.selectedClinic),
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
    : super(
        AppointmentState(
          appointments: const AsyncValue.loading(),
          selectedDate: DateTime.now(),
        ),
      ) {
    _initRealtime();
    _loadInitialData();
  }

  final Ref ref;

  void _invalidateConsumers() {
    ref.invalidate(allAppointmentsProvider);
    ref.invalidate(dashboardSummaryProvider);
  }

  void _initRealtime() {
    final realtime = ref.read(realtimeServiceProvider);
    realtime.on('AppointmentUpdated', (args) => refresh());
    realtime.on('AppointmentCreated', (args) => refresh());
  }

  Future<void> _loadInitialData() async {
    try {
      final clinics = await ref.read(proceduresRepositoryProvider).getClinics(onlyActive: true);
      state = state.copyWith(clinics: clinics);
      if (clinics.isNotEmpty) selectClinic(clinics.first);
      else await refresh();
    } catch (e, stack) {
      state = state.copyWith(appointments: AsyncValue.error(e, stack));
    }
  }

  Future<void> selectClinic(Clinic? clinic) async {
    state = state.copyWith(selectedClinic: clinic, clearClinic: clinic == null);
    await refresh();
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(appointments: const AsyncValue.loading());
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(appointmentRepositoryProvider);
      final date = state.selectedDate;
      return await repository.getAppointments(
        start: DateTime(date.year, date.month, date.day, 0, 0),
        end: DateTime(date.year, date.month, date.day, 23, 59, 59),
        clinicId: state.selectedClinic?.id,
      );
    });
    state = state.copyWith(appointments: result);
  }

  Future<void> fetchInstitutionalData() async {
    state = state.copyWith(institutionalAppointments: const AsyncValue.loading());
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(appointmentRepositoryProvider);
      final date = state.selectedDate;
      return await repository.getAppointments(
        start: DateTime(date.year, date.month, date.day, 0, 0),
        end: DateTime(date.year, date.month, date.day, 23, 59, 59),
        clinicId: null,
      );
    });
    state = state.copyWith(institutionalAppointments: result);
  }

  Future<void> schedule(Appointment appointment) async {
    await ref.read(appointmentRepositoryProvider).scheduleAppointment(appointment);
    _invalidateConsumers();
    await refresh();
    await fetchInstitutionalData();
  }

  Future<void> updateStatus(String id, AppointmentStatus status) async {
    await ref.read(appointmentRepositoryProvider).updateAppointmentStatus(id, status);
    _invalidateConsumers();
    await refresh();
  }

  Future<void> registerArrival(String id) async {
    await ref.read(appointmentRepositoryProvider).registerArrival(id);
    _invalidateConsumers();
    await refresh();
  }

  Future<void> registerStart(String id) async {
    await ref.read(appointmentRepositoryProvider).registerStart(id);
    _invalidateConsumers();
    await refresh();
  }

  Future<void> registerFinish(String id) async {
    await ref.read(appointmentRepositoryProvider).registerFinish(id);
    _invalidateConsumers();
    await refresh();
  }

  Map<String, dynamic> getDayStats() {
    final list = state.appointments.value ?? [];
    int total = list.length;
    int completed = list.where((a) => a.status == AppointmentStatus.completed).length;
    int missed = list.where((a) => a.status == AppointmentStatus.missed || a.status == AppointmentStatus.noShow).length;
    
    double occupancy = 0.0;
    if (state.selectedClinic != null && state.selectedClinic!.capacity > 0) {
      final hours = (state.selectedClinic!.endHour - state.selectedClinic!.startHour) - 2; // -2 almoço
      final totalCapacity = hours * state.selectedClinic!.capacity;
      occupancy = total / totalCapacity;
    }

    return {
      'total': total,
      'completed': completed,
      'missed': missed,
      'occupancy': occupancy,
    };
  }
}

final appointmentViewModelProvider = StateNotifierProvider<AppointmentViewModel, AppointmentState>((ref) {
  return AppointmentViewModel(ref);
});
