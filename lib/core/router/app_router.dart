import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/splash_screen.dart';
import '../../features/dashboard/presentation/views/dashboard_screen.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/patients/presentation/views/patient_list_screen.dart';
import '../../features/patients/presentation/views/add_patient_screen.dart';
import '../../features/prontuario/presentation/views/prontuario_screen.dart';
import '../../features/patients/domain/entities/patient.dart';
import '../../features/users/presentation/views/user_list_screen.dart';
import '../../features/users/presentation/views/add_user_screen.dart';
import '../../features/agenda/presentation/views/agenda_screen.dart';
import '../../features/agenda/presentation/views/add_appointment_screen.dart';
import '../../features/agenda/presentation/views/wait_list_screen.dart';
import '../../features/agenda/presentation/views/institutional_agenda_screen.dart';
import '../../features/procedures/presentation/views/clinic_management_screen.dart';
import '../../features/procedures/domain/entities/clinic.dart';
import '../../features/prontuario/presentation/views/prescription_screen.dart';
import '../../features/prontuario/presentation/views/certificate_screen.dart';
import '../../features/prontuario/presentation/views/anamnese_screen.dart';
import '../../features/prontuario/presentation/views/treatment_plan_screen.dart';
import '../../features/prontuario/presentation/views/endodontia_screen.dart';
import '../../features/prontuario/presentation/views/odontogram_screen.dart';
import '../../features/prontuario/presentation/views/periograma_screen.dart';
import '../../features/prontuario/presentation/views/evolution_screen.dart';
import '../../features/prontuario/presentation/views/exame_extraoral_screen.dart';
import '../../features/prontuario/presentation/views/exame_intraoral_screen.dart';
import '../../features/prontuario/presentation/views/exams_screen.dart';
import '../../features/reports/presentation/views/reports_screen.dart';
import '../../features/settings/presentation/views/settings_screen.dart';
import '../../features/notifications/presentation/views/notification_list_screen.dart';
import '../../features/audit/presentation/views/audit_log_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _RouterRefreshStream(ref.watch(authViewModelProvider.notifier).stream),
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';
      final isLoggedIn = authState.user != null;
      final isInitialized = authState.isInitialized;

      if (!isInitialized) return null;
      if (isSplash) return isLoggedIn ? '/dashboard' : '/login';
      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'patients',
            builder: (context, state) => const PatientListScreen(),
            routes: [
              GoRoute(path: 'add', builder: (context, state) => const AddPatientScreen()),
              GoRoute(
                path: 'prontuario',
                builder: (context, state) => ProntuarioScreen(patient: state.extra as Patient),
                routes: [
                  GoRoute(path: 'odontogram', builder: (context, state) => OdontogramScreen(patientId: state.uri.queryParameters['patientId']!, patientName: state.uri.queryParameters['patientName']!)),
                  GoRoute(path: 'evolution', builder: (context, state) => EvolutionScreen(patientId: state.uri.queryParameters['patientId']!, patientName: state.uri.queryParameters['patientName']!)),
                  GoRoute(path: 'exams', builder: (context, state) => ExamsScreen(patientId: state.uri.queryParameters['patientId']!, patientName: state.uri.queryParameters['patientName']!)),
                  GoRoute(path: 'prescription', builder: (context, state) => PrescriptionScreen(patientId: state.uri.queryParameters['patientId']!)),
                  GoRoute(path: 'certificate', builder: (context, state) => CertificateScreen(patientId: state.uri.queryParameters['patientId']!, patientName: state.uri.queryParameters['patientName']!)),
                  GoRoute(path: 'anamnese', builder: (context, state) => AnamneseScreen(patientId: state.uri.queryParameters['patientId']!, patientName: state.uri.queryParameters['patientName']!)),
                  GoRoute(path: 'extraoral', builder: (context, state) => ExameExtraoralScreen(patientId: state.uri.queryParameters['patientId']!, patientName: state.uri.queryParameters['patientName']!)),
                  GoRoute(path: 'intraoral', builder: (context, state) => ExameIntraoralScreen(patientId: state.uri.queryParameters['patientId']!, patientName: state.uri.queryParameters['patientName']!)),
                  GoRoute(path: 'periograma', builder: (context, state) => PeriogramaScreen(patientId: state.uri.queryParameters['patientId']!, patientName: state.uri.queryParameters['patientName']!)),
                  GoRoute(path: 'endodontia', builder: (context, state) => EndodontiaScreen(patientId: state.uri.queryParameters['patientId']!, patientName: state.uri.queryParameters['patientName']!)),
                  GoRoute(path: 'treatment-plan', builder: (context, state) => TreatmentPlanScreen(patientId: state.uri.queryParameters['patientId']!, patientName: state.uri.queryParameters['patientName']!)),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'users',
            builder: (context, state) => const UserListScreen(),
            routes: [GoRoute(path: 'add', builder: (context, state) => const AddUserScreen())],
          ),
          GoRoute(
            path: 'agenda',
            builder: (context, state) => const AgendaScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) {
                  if (state.extra is Map<String, dynamic>) {
                    final extra = state.extra as Map<String, dynamic>;
                    return AddAppointmentScreen(
                      initialClinic: extra['clinic'] as Clinic?,
                      initialDateTime: extra['time'] as DateTime?,
                    );
                  }
                  return AddAppointmentScreen(initialClinic: state.extra as Clinic?);
                },
              ),
              GoRoute(path: 'institutional', builder: (context, state) => const InstitutionalAgendaScreen()),
              GoRoute(
                path: 'wait-list',
                builder: (context, state) => WaitListScreen(
                  clinicId: state.uri.queryParameters['clinicId']!,
                  clinicName: state.uri.queryParameters['clinicName']!,
                ),
              ),
            ],
          ),
          GoRoute(path: 'clinics', builder: (context, state) => const ClinicManagementScreen()),
          GoRoute(path: 'reports', builder: (context, state) => const ReportsScreen()),
          GoRoute(path: 'settings', builder: (context, state) => const SettingsScreen()),
          GoRoute(path: 'notifications', builder: (context, state) => const NotificationListScreen()),
          GoRoute(path: 'audit-logs', builder: (context, state) => const AuditLogScreen()),
        ],
      ),
    ],
  );
});

class _RouterRefreshStream extends ChangeNotifier {
  _RouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final dynamic _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
