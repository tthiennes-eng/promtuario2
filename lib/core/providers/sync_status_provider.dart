import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/core/providers/providers.dart';

/// Conta o número total de registros pendentes de sincronização (isSynced == false) no SQLite local.
final pendingSyncCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final unsyncedPatients = await (db.select(db.patientsLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedAppointments = await (db.select(db.appointmentsLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedEvolutions = await (db.select(db.evolutionsLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedSheets = await (db.select(db.odontogramLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedWaitList = await (db.select(db.waitListLocal)..where((t) => t.isSynced.equals(false))).get();

  return unsyncedPatients.length +
      unsyncedAppointments.length +
      unsyncedEvolutions.length +
      unsyncedSheets.length +
      unsyncedWaitList.length;
});

/// Dispara a sincronização de todos os dados offline pendentes com o servidor.
Future<int> syncAllPendingRecords(WidgetRef ref) async {
  await ref.read(patientRepositoryProvider).syncPatients();
  await ref.read(appointmentRepositoryProvider).syncAppointments();
  ref.invalidate(pendingSyncCountProvider);
  return await ref.read(pendingSyncCountProvider.future);
}
