import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/core/providers/providers.dart';

class PendingSyncSummary {
  final int patients;
  final int appointments;
  final int evolutions;
  final int sheets;
  final int waitList;

  const PendingSyncSummary({
    this.patients = 0,
    this.appointments = 0,
    this.evolutions = 0,
    this.sheets = 0,
    this.waitList = 0,
  });

  int get total => patients + appointments + evolutions + sheets + waitList;

  String get breakdown {
    final parts = <String>[];
    if (patients > 0) parts.add('$patients paciente(s)');
    if (appointments > 0) parts.add('$appointments agendamento(s)');
    if (evolutions > 0) parts.add('$evolutions evolução(ões)');
    if (sheets > 0) parts.add('$sheets ficha(s) clínica(s)');
    if (waitList > 0) parts.add('$waitList lista de espera');
    return parts.join(', ');
  }
}

/// Detalha os registros pendentes de sincronização (isSynced == false) no SQLite local.
final pendingSyncSummaryProvider = FutureProvider.autoDispose<PendingSyncSummary>((ref) async {
  final db = ref.watch(databaseProvider);
  final unsyncedPatients = await (db.select(db.patientsLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedAppointments = await (db.select(db.appointmentsLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedEvolutions = await (db.select(db.evolutionsLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedSheets = await (db.select(db.odontogramLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedWaitList = await (db.select(db.waitListLocal)..where((t) => t.isSynced.equals(false))).get();

  return PendingSyncSummary(
    patients: unsyncedPatients.length,
    appointments: unsyncedAppointments.length,
    evolutions: unsyncedEvolutions.length,
    sheets: unsyncedSheets.length,
    waitList: unsyncedWaitList.length,
  );
});

/// Conta o número total de registros pendentes de sincronização (isSynced == false) no SQLite local.
final pendingSyncCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final summary = await ref.watch(pendingSyncSummaryProvider.future);
  return summary.total;
});

/// Dispara a sincronização de todas as tabelas offline pendentes com o servidor.
Future<PendingSyncSummary> syncAllPendingRecords(WidgetRef ref) async {
  Future<void> safeRun(Future<void> Function() task) async {
    try {
      await task();
    } catch (_) {}
  }

  await safeRun(() => ref.read(patientRepositoryProvider).syncPatients());
  await safeRun(() => ref.read(appointmentRepositoryProvider).syncAppointments());
  await safeRun(() => ref.read(prontuarioRepositoryProvider).syncPendingData());
  await safeRun(() => ref.read(waitListRepositoryProvider).syncWaitList());

  ref.invalidate(pendingSyncSummaryProvider);
  ref.invalidate(pendingSyncCountProvider);
  return await ref.read(pendingSyncSummaryProvider.future);
}
