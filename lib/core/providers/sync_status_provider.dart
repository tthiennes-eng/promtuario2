import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promt/core/network/sync_service.dart';
import 'package:promt/core/providers/providers.dart';

class PendingSyncSummary {
  final int patients;
  final int appointments;
  final int evolutions;
  final int sheets;
  final int waitList;
  final int attachments;
  final int auditLogs;

  const PendingSyncSummary({
    this.patients = 0,
    this.appointments = 0,
    this.evolutions = 0,
    this.sheets = 0,
    this.waitList = 0,
    this.attachments = 0,
    this.auditLogs = 0,
  });

  int get total => patients + appointments + evolutions + sheets + waitList + attachments + auditLogs;

  String get breakdown {
    final parts = <String>[];
    if (patients > 0) parts.add('$patients paciente(s)');
    if (appointments > 0) parts.add('$appointments agendamento(s)');
    if (evolutions > 0) parts.add('$evolutions evolução(ões)');
    if (sheets > 0) parts.add('$sheets ficha(s) clínica(s)');
    if (waitList > 0) parts.add('$waitList lista de espera');
    if (attachments > 0) parts.add('$attachments anexo(s)');
    if (auditLogs > 0) parts.add('$auditLogs log(s) de auditoria');
    return parts.join(', ');
  }
}

/// Detalha os registros pendentes de sincronização (isSynced == false) no SQLite local.
final pendingSyncSummaryProvider = FutureProvider.autoDispose<PendingSyncSummary>((ref) async {
  final db = ref.watch(databaseProvider);
  final unsyncedPatients = await (db.select(db.patientsLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedAppointments = await (db.select(db.appointmentsLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedEvolutions = await (db.select(db.evolutionsLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedOdontograms = await (db.select(db.odontogramLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedAnamneses = await (db.select(db.anamneseLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedWaitList = await (db.select(db.waitListLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedAttachments = await (db.select(db.attachmentsLocal)..where((t) => t.isSynced.equals(false))).get();
  final unsyncedAudits = await (db.select(db.auditLocal)..where((t) => t.isSynced.equals(false))).get();

  return PendingSyncSummary(
    patients: unsyncedPatients.length,
    appointments: unsyncedAppointments.length,
    evolutions: unsyncedEvolutions.length,
    sheets: unsyncedOdontograms.length + unsyncedAnamneses.length,
    waitList: unsyncedWaitList.length,
    attachments: unsyncedAttachments.length,
    auditLogs: unsyncedAudits.length,
  );
});

/// Conta o número total de registros pendentes de sincronização (isSynced == false) no SQLite local.
final pendingSyncCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final summary = await ref.watch(pendingSyncSummaryProvider.future);
  return summary.total;
});

/// Dispara a sincronização de todas as tabelas offline pendentes com o servidor.
Future<PendingSyncSummary> syncAllPendingRecords(WidgetRef ref) async {
  try {
    await ref.read(syncServiceProvider).syncAll();
  } catch (_) {}

  ref.invalidate(pendingSyncSummaryProvider);
  ref.invalidate(pendingSyncCountProvider);
  return await ref.read(pendingSyncSummaryProvider.future);
}
