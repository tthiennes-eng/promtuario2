import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:promt/core/network/realtime_service.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/agenda/domain/repositories/i_appointment_repository.dart';
import 'package:promt/features/agenda/presentation/views/add_appointment_screen.dart';
import 'package:promt/features/agenda/presentation/views/agenda_screen.dart';
import 'package:promt/features/auth/domain/entities/user.dart';
import 'package:promt/features/patients/domain/entities/patient.dart';
import 'package:promt/features/patients/domain/repositories/i_patient_repository.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/features/procedures/domain/entities/procedure.dart';
import 'package:promt/features/procedures/domain/repositories/i_procedures_repository.dart';
import 'package:promt/features/users/domain/repositories/i_user_management_repository.dart';

class _FakePatientRepository implements IPatientRepository {
  @override
  Future<List<Patient>> getPatients({int page = 1, String? query}) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeUserRepository implements IUserManagementRepository {
  @override
  Future<List<User>> getUsers({UserRole? role, String? query}) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeRealtimeService implements RealtimeService {
  @override
  void on(String eventName, void Function(List<Object?>?) handler) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeProceduresRepository implements IProceduresRepository {
  final List<Clinic> clinics;
  _FakeProceduresRepository(this.clinics);

  @override
  Future<List<Clinic>> getClinics({bool onlyActive = false}) async => clinics;

  @override
  Future<void> saveClinic(Clinic clinic) async {}

  @override
  Future<void> syncClinics() async {}

  @override
  Future<List<Procedure>> getProceduresByClinic(String clinicId) async => [];

  @override
  Future<List<Procedure>> getAllProcedures() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _InMemoryAppointmentRepository implements IAppointmentRepository {
  final List<Appointment> store;
  AppointmentStatus? lastUpdatedStatus;
  String? lastUpdatedId;

  _InMemoryAppointmentRepository(this.store);

  @override
  Future<List<Appointment>> getAppointments({
    required DateTime start,
    required DateTime end,
    String? clinicId,
  }) async {
    return store.where((a) {
      if (clinicId != null && a.clinicId != clinicId) return false;
      return !a.startTime.isBefore(start) && !a.startTime.isAfter(end);
    }).toList();
  }

  @override
  Future<Appointment> scheduleAppointment(Appointment appointment) async {
    store.add(appointment);
    return appointment;
  }

  @override
  Future<void> updateAppointmentStatus(String id, AppointmentStatus status) async {
    lastUpdatedId = id;
    lastUpdatedStatus = status;
    for (int i = 0; i < store.length; i++) {
      if (store[i].id == id) {
        store[i] = store[i].copyWith(status: status);
      }
    }
  }

  @override
  Future<void> registerArrival(String id) async => updateAppointmentStatus(id, AppointmentStatus.arrived);

  @override
  Future<void> registerStart(String id) async => updateAppointmentStatus(id, AppointmentStatus.inProgress);

  @override
  Future<void> registerFinish(String id) async => updateAppointmentStatus(id, AppointmentStatus.completed);

  @override
  Future<void> rescheduleAppointment(String id, DateTime newStart, DateTime newEnd) async {}

  @override
  Future<void> syncAppointments() async {}
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  test('AppointmentStatus.apiValue matches backend C# enum values 1..8 and round-trips via fromJson', () {
    expect(AppointmentStatus.scheduled.apiValue, 1);
    expect(AppointmentStatus.confirmed.apiValue, 2);
    expect(AppointmentStatus.arrived.apiValue, 3);
    expect(AppointmentStatus.inProgress.apiValue, 4);
    expect(AppointmentStatus.completed.apiValue, 5);
    expect(AppointmentStatus.cancelled.apiValue, 6);
    expect(AppointmentStatus.noShow.apiValue, 7);
    expect(AppointmentStatus.missed.apiValue, 8);

    final fromInt = Appointment.fromJson({
      'id': 'a1',
      'patientId': 'p1',
      'patientName': 'Paciente Teste',
      'doctorId': 'd1',
      'clinicId': 'c1',
      'startTime': '2026-11-26T09:00:00Z',
      'endTime': '2026-11-26T10:00:00Z',
      'status': 7,
    });
    expect(fromInt.status, AppointmentStatus.noShow);
    expect(fromInt.status.displayName, 'Falta');

    final fromNumericStr = Appointment.fromJson({
      'id': 'a2',
      'patientId': 'p1',
      'patientName': 'Paciente Teste',
      'doctorId': 'd1',
      'clinicId': 'c1',
      'startTime': '2026-11-26T09:00:00Z',
      'endTime': '2026-11-26T10:00:00Z',
      'status': '8',
    });
    expect(fromNumericStr.status, AppointmentStatus.missed);
  });

  testWidgets('AgendaScreen updates appointment status and Faltas counter when Falta is selected', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 9, 0);
    final end = DateTime(now.year, now.month, now.day, 10, 0);

    final clinic = Clinic(
      id: 'clinic-1',
      name: 'Clinica I',
      startHour: 8,
      endHour: 12,
      slotDurationMinutes: 60,
    );

    final repo = _InMemoryAppointmentRepository([
      Appointment(
        id: 'appt-1',
        patientId: 'pat-1',
        patientName: 'Paciente Teste 01',
        doctorId: 'doc-1',
        doctorName: 'Dr. Teste',
        startTime: start,
        endTime: end,
        status: AppointmentStatus.scheduled,
        procedureName: 'Avaliação',
        clinicId: clinic.id,
        clinicName: clinic.name,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          realtimeServiceProvider.overrideWithValue(_FakeRealtimeService()),
          proceduresRepositoryProvider.overrideWithValue(_FakeProceduresRepository([clinic])),
          appointmentRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: AgendaScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PACIENTE TESTE 01'), findsOneWidget);
    expect(find.text('Agendado'), findsOneWidget);

    // Clicar no paciente agendado para abrir detalhes
    await tester.tap(find.text('PACIENTE TESTE 01'));
    await tester.pumpAndSettle();

    // Selecionar Falta
    await tester.tap(find.text('Falta'));
    await tester.pumpAndSettle();

    expect(repo.lastUpdatedId, 'appt-1');
    expect(repo.lastUpdatedStatus, AppointmentStatus.noShow);
    expect(find.text('Falta'), findsOneWidget);
    expect(find.text('Falta registrada com sucesso.'), findsOneWidget);
  });

  testWidgets('Tapping a free date/time slot in AgendaScreen opens Novo Agendamento with that exact date and time', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final clinic = Clinic(
      id: 'clinic-1',
      name: 'Clinica I',
      startHour: 8,
      endHour: 12,
      slotDurationMinutes: 60,
    );

    final repo = _InMemoryAppointmentRepository([]);
    DateTime? receivedTime;
    Clinic? receivedClinic;

    final router = GoRouter(
      initialLocation: '/dashboard/agenda',
      routes: [
        GoRoute(
          path: '/dashboard/agenda',
          builder: (context, state) => const AgendaScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                receivedClinic = extra['clinic'] as Clinic?;
                receivedTime = extra['time'] as DateTime?;
                return Scaffold(
                  appBar: AppBar(title: const Text('Novo Agendamento')),
                  body: Column(
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(receivedTime!)),
                      Text(DateFormat('HH:mm').format(receivedTime!)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          realtimeServiceProvider.overrideWithValue(_FakeRealtimeService()),
          proceduresRepositoryProvider.overrideWithValue(_FakeProceduresRepository([clinic])),
          appointmentRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Avança 1 dia na agenda
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final expectedDate = DateFormat('dd/MM/yyyy').format(tomorrow);

    // Toca no horário disponível de 10:00
    await tester.tap(find.text('10:00'));
    await tester.pumpAndSettle();

    expect(receivedClinic?.name, 'Clinica I');
    expect(receivedTime, isNotNull);
    expect(receivedTime!.year, tomorrow.year);
    expect(receivedTime!.month, tomorrow.month);
    expect(receivedTime!.day, tomorrow.day);
    expect(receivedTime!.hour, 10);
    expect(receivedTime!.minute, 0);
    expect(find.text(expectedDate), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
  });

  testWidgets('AddAppointmentScreen renders pre-filled initialDateTime date and 24h time', (tester) async {
    final target = DateTime(2026, 12, 15, 14, 30);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          realtimeServiceProvider.overrideWithValue(_FakeRealtimeService()),
          patientRepositoryProvider.overrideWithValue(_FakePatientRepository()),
          userManagementRepositoryProvider.overrideWithValue(_FakeUserRepository()),
          proceduresRepositoryProvider.overrideWithValue(_FakeProceduresRepository(const [])),
          appointmentRepositoryProvider.overrideWithValue(_InMemoryAppointmentRepository([])),
        ],
        child: MaterialApp(
          home: AddAppointmentScreen(initialDateTime: target),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('15/12/2026'), findsOneWidget);
    expect(find.text('14:30'), findsOneWidget);
  });
}
