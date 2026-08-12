import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/core/network/realtime_service.dart';
import 'package:promt/features/patients/presentation/viewmodels/patient_viewmodel.dart';

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
          
          final appJson = app.toJson();
          final student = appJson['studentName']?.toString() ?? app.doctorName;
          final professor = appJson['professorName']?.toString() ?? "";
          
          if (filterStudent != null && !student.toLowerCase().contains(filterStudent!.toLowerCase())) return false;
          if (filterProfessor != null && !professor.toLowerCase().contains(filterProfessor!.toLowerCase())) return false;
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
    
    final clinicJson = selectedClinic!.toJson();
    final startHour = clinicJson['startHour'] as int? ?? 8;
    final endHour = clinicJson['endHour'] as int? ?? 18;
    final duration = clinicJson['slotDurationMinutes'] as int? ?? 60;
    
    final dayAppointments = appointments.value ?? [];

    for (int hour = startHour; hour < endHour; hour++) {
      // Pula horários de almoço (11h, 12h, 13h) conforme solicitado
      if (hour == 11 || hour == 12 || hour == 13) continue;

      for (int min = 0; min < 60; min += (duration > 0 ? duration : 60)) {
        final slotStart = DateTime(date.year, date.month, date.day, hour, min);
        final slotEnd = slotStart.add(Duration(minutes: duration > 0 ? duration : 60));
        
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

  final List<String> _defaultClinicNames = [
    'Clinica I', 'Clinica II', 'Clinica III', 'Clinica IV', 'Clinica V',
    'Clinica Integrada Infantil', 'Clinica de Emergência',
    'Clinica Integrada Adulto I', 'Clinica Integrada Adulto II',
    'Clinica de DTM', 'Clinica de Odontopediatria'
  ];

  void _initRealtime() {
    final realtime = ref.read(realtimeServiceProvider);
    realtime.on('AppointmentUpdated', (args) => refresh());
  }

  Future<void> _loadInitialData() async {
    try {
      final proceduresRepo = ref.read(proceduresRepositoryProvider);
      var clinics = await proceduresRepo.getClinics(onlyActive: true);
      
      // Se não houver clínicas no banco, popula com os nomes padrão para que a agenda funcione
      if (clinics.isEmpty) {
        clinics = _defaultClinicNames.map((name) => Clinic(
          id: name, // Usa o nome como ID se não houver registro no banco
          name: name,
          description: 'Clínica Escola',
          isActive: true,
          capacity: 1,
          startHour: 8,
          endHour: 18,
          slotDurationMinutes: 60,
          metadata: {},
        )).toList();
      }

      state = state.copyWith(clinics: clinics);
      if (clinics.isNotEmpty) selectClinic(clinics.first);
    } catch (e, stack) {
      state = state.copyWith(appointments: AsyncValue.error(e, stack));
    }
  }

  void setFilters({
    AgendaDayPeriod? period,
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
      period: AgendaDayPeriod.all,
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
    // Invalida o provider de histórico global para que a lista de pacientes reflita a mudança na hora
    ref.invalidate(allAppointmentsProvider);
    await refresh();
  }

  Future<void> updateStatus(String id, AppointmentStatus status) async {
    await ref.read(appointmentRepositoryProvider).updateAppointmentStatus(id, status);
    await refresh();
  }

  Map<String, dynamic> getDayStats() {
    final list = state.appointments.value ?? [];
    double occupancy = 0.0;
    
    if (state.selectedClinic != null) {
      final clinic = state.selectedClinic!;
      final clinicJson = clinic.toJson();
      final startHour = clinicJson['startHour'] as int? ?? 8;
      final endHour = clinicJson['endHour'] as int? ?? 18;
      final duration = clinicJson['slotDurationMinutes'] as int? ?? 60;
      
      final workingMinutes = (endHour - startHour) * 60;
      final slotsPerChair = workingMinutes / (duration > 0 ? duration : 60);
      final totalCapacity = slotsPerChair * (clinic.capacity > 0 ? clinic.capacity : 1);
      
      if (totalCapacity > 0) {
        occupancy = list.length / totalCapacity;
      }
    }

    return {
      'total': list.length,
      'completed': list.where((a) => a.status == AppointmentStatus.completed).length,
      'missed': list.where((a) => a.status == AppointmentStatus.missed).length,
      'canceled': list.where((a) => a.status == AppointmentStatus.cancelled).length,
      'occupancy': occupancy,
    };
  }
}

final appointmentViewModelProvider = StateNotifierProvider<AppointmentViewModel, AppointmentState>((ref) {
  return AppointmentViewModel(ref);
});
