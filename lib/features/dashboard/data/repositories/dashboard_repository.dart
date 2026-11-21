import 'dart:async';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:promt/features/dashboard/domain/repositories/i_dashboard_repository.dart';

/// Implementação local do repositório do dashboard.
class DashboardRepository implements IDashboardRepository {
  DashboardRepository(this._localDb);

  final AppDatabase _localDb;

  @override
  Stream<DashboardSummary> watchSummary() {
    late StreamController<DashboardSummary> controller;
    final subscriptions = <StreamSubscription<dynamic>>[];

    Future<void> emitSummary() async {
      if (controller.isClosed) return;
      try {
        controller.add(await _readSummary());
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
      }
    }

    controller = StreamController<DashboardSummary>(
      onListen: () {
        emitSummary();
        final db = _localDb;
        subscriptions.add(db.select(db.patientsLocal).watch().listen((_) => emitSummary()));
        subscriptions.add(db.select(db.appointmentsLocal).watch().listen((_) => emitSummary()));
        subscriptions.add(db.select(db.evolutionsLocal).watch().listen((_) => emitSummary()));
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );

    return controller.stream;
  }

  Future<DashboardSummary> _readSummary() async {
    final db = _localDb;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final startOfMonth = DateTime(now.year, now.month);

    final patients = await db.select(db.patientsLocal).get();

    final appointmentRows = await db.select(db.appointmentsLocal).get();
    final agendamentosHoje = appointmentRows.where((row) {
      return !row.startTime.isBefore(startOfDay) &&
          row.startTime.isBefore(endOfDay);
    }).length;


    final evolutionRows = await db.select(db.evolutionsLocal).get();
    final startOfNextMonth = DateTime(now.year, now.month + 1);
    final attendanceThisMonth = evolutionRows.where((row) {
      return row.createdAt.isAfter(startOfMonth) &&
          row.createdAt.isBefore(startOfNextMonth);
    }).length;

    return DashboardSummary(
      totalPacientes: patients.length,
      agendamentosHoje: agendamentosHoje,
      atendimentos: attendanceThisMonth,
    );
  }
}
