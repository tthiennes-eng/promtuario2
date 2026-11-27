import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:promt/core/network/realtime_service.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:promt/core/security/storage_service.dart';
import 'package:promt/features/agenda/domain/entities/appointment.dart';
import 'package:promt/features/agenda/domain/repositories/i_appointment_repository.dart';
import 'package:promt/features/agenda/presentation/views/agenda_screen.dart';
import 'package:promt/features/auth/domain/entities/user.dart';
import 'package:promt/features/patients/domain/entities/patient.dart';
import 'package:promt/features/patients/domain/repositories/i_patient_repository.dart';
import 'package:promt/features/patients/presentation/viewmodels/patient_viewmodel.dart';
import 'package:promt/features/procedures/domain/entities/clinic.dart';
import 'package:promt/features/procedures/domain/entities/procedure.dart';
import 'package:promt/features/procedures/domain/repositories/i_procedures_repository.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/endodontia_viewmodel.dart';
import 'package:promt/features/prontuario/presentation/viewmodels/prontuario_summary_provider.dart';
import 'package:promt/features/prontuario/presentation/views/prontuario_screen.dart';
import 'package:promt/features/users/domain/repositories/i_user_management_repository.dart';

class _InMemorySecureStorage extends FlutterSecureStorage {
  final Map<String, String> backing;
  _InMemorySecureStorage(this.backing);

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      backing.remove(key);
    } else {
      backing[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      backing[key];

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    backing.remove(key);
  }
}

class _FakeEndoNotifier extends EndodontiaViewModel {
  _FakeEndoNotifier(super.ref, super.patientId, Map<String, dynamic>? initial) {
    state = AsyncValue.data(initial);
  }

  @override
  Future<void> load() async {}

  @override
  Future<void> save(Map<String, dynamic> data) async {
    state = AsyncValue.data(data);
  }
}

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
  Future<List<Procedure>> getProceduresByClinic(String clinicId) async => const [];

  @override
  Future<List<Procedure>> getAllProcedures() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeAppointmentRepository implements IAppointmentRepository {
  final List<Appointment> items;
  _FakeAppointmentRepository(this.items);

  @override
  Future<List<Appointment>> getAppointments({
    required DateTime start,
    required DateTime end,
    String? clinicId,
  }) async =>
      items;

  @override
  Future<Appointment> scheduleAppointment(Appointment appointment) async => appointment;

  @override
  Future<void> updateAppointmentStatus(String id, AppointmentStatus status) async {}

  @override
  Future<void> registerArrival(String id) async {}

  @override
  Future<void> registerStart(String id) async {}

  @override
  Future<void> registerFinish(String id) async {}

  @override
  Future<void> rescheduleAppointment(String id, DateTime newStart, DateTime newEnd) async {}

  @override
  Future<void> syncAppointments() async {}
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  group('StorageService security & preferences', () {
    test('purges legacy plaintext saved_password and persists push preference', () async {
      final backing = <String, String>{
        'saved_password': 'legacy-secret-password',
      };
      final storage = StorageService(_InMemorySecureStorage(backing));

      await storage.saveSavedCredentials(
        email: 'doc@ufma.br',
        password: 'should-not-be-saved',
      );
      expect(await storage.getSavedEmail(), 'doc@ufma.br');
      expect(await storage.getSavedPassword(), isNull);
      expect(backing.containsKey('saved_password'), isFalse);

      expect(await storage.getPushNotificationsEnabled(), isTrue);
      await storage.savePushNotificationsEnabled(false);
      expect(await storage.getPushNotificationsEnabled(), isFalse);
    });
  });

  group('ProntuarioScreen pediatric alerts', () {
    testWidgets('displays red Allergy and orange Comorbidity alerts from Odontopediatria sheet', (tester) async {
      final patient = Patient(
        id: 'pat-ped-1',
        fullName: 'Lucas Pediátrico',
        cpf: '12345678900',
        birthDate: DateTime(2018, 5, 10),
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            endodontiaViewModelProvider('anamnese_pat-ped-1').overrideWith(
              (ref) => _FakeEndoNotifier(ref, 'anamnese_pat-ped-1', null),
            ),
            endodontiaViewModelProvider('odontopediatria_pat-ped-1').overrideWith(
              (ref) => _FakeEndoNotifier(ref, 'odontopediatria_pat-ped-1', {
                'fields': {
                  't4_hb_q17_alergia_anestesico': '(1) Sim',
                  't5_hma_alergia': '(1) Sim',
                  't5_hma_alergia_qual': 'Dipirona',
                  't5_hma_tratamento_medico': '(1) Sim',
                  't5_hma_tratamento_qual': 'Asma',
                  't5_hmat_respiracao': 'Bucal',
                },
              }),
            ),
            prontuarioSummaryProvider('pat-ped-1').overrideWith((ref) async => const <String, dynamic>{}),
            allAppointmentsProvider.overrideWith((ref) async => const <Appointment>[]),
            proceduresRepositoryProvider.overrideWithValue(_FakeProceduresRepository(const [])),
          ],
          child: MaterialApp(home: ProntuarioScreen(patient: patient)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ALERTA DE SAÚDE / ALERGIA'), findsOneWidget);
      expect(find.textContaining('Alergia a anestésico (Odontopediatria)'), findsOneWidget);
      expect(find.textContaining('Dipirona (Odontopediatria)'), findsOneWidget);

      expect(find.text('ALERTA DE COMORBIDADE'), findsOneWidget);
      expect(find.textContaining('Tratamento médico (Pediatria): Asma'), findsOneWidget);
      expect(find.textContaining('Respiração: Bucal (Pediatria)'), findsOneWidget);
    });
  });

  group('AgendaScreen quick actions modal', () {
    testWidgets('shows Abrir Prontuário and Reagendar buttons when tapping an appointment', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final clinic = Clinic(
        id: 'clinic-1',
        name: 'Clínica I',
        location: 'Bloco A',
        startHour: 8,
        endHour: 12,
        slotDurationMinutes: 60,
      );
      final now = DateTime.now();
      final appt = Appointment(
        id: 'appt-1',
        patientId: 'pat-1',
        patientName: 'Paciente Teste',
        doctorId: 'doc-1',
        doctorName: 'Dr. Teste',
        clinicId: 'clinic-1',
        clinicName: 'Clínica I',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 10, 0),
        status: AppointmentStatus.scheduled,
        procedureName: 'Profilaxia',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            proceduresRepositoryProvider.overrideWithValue(_FakeProceduresRepository([clinic])),
            appointmentRepositoryProvider.overrideWithValue(_FakeAppointmentRepository([appt])),
            patientRepositoryProvider.overrideWithValue(_FakePatientRepository()),
            userManagementRepositoryProvider.overrideWithValue(_FakeUserRepository()),
            realtimeServiceProvider.overrideWithValue(_FakeRealtimeService()),
          ],
          child: const MaterialApp(home: AgendaScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('PACIENTE TESTE'));
      await tester.pumpAndSettle();

      expect(find.text('Abrir Prontuário'), findsOneWidget);
      expect(find.text('Reagendar'), findsOneWidget);
      expect(find.text('Falta'), findsOneWidget);
    });
  });
}
