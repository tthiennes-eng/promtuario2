import 'dart:async';
import 'package:logging/logging.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:promt/features/dashboard/domain/repositories/i_dashboard_repository.dart';

class DashboardRepository implements IDashboardRepository {
  DashboardRepository(this._localDb);

  final AppDatabase _localDb;
  final _logger = Logger('DashboardRepository');

  /// Converte dinamicamente qualquer valor para DateTime de forma segura.
  DateTime _safeParse(dynamic v) {
    if (v == null || v.toString().trim().isEmpty || v.toString() == 'null') {
      return DateTime.now();
    }
    if (v is DateTime) return v.isUtc ? v.toLocal() : v;
    if (v is int) {
      if (v < 10000000000) return DateTime.fromMillisecondsSinceEpoch(v * 1000).toLocal();
      return DateTime.fromMillisecondsSinceEpoch(v).toLocal();
    }
    try {
      final s = v.toString();
      final dateStr = (s.contains('T') || s.contains(' ')) ? s : '${s}T00:00:00';
      final dt = DateTime.parse(dateStr);
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  Stream<DashboardSummary> watchSummary() {
    late StreamController<DashboardSummary> controller;
    final subscriptions = <StreamSubscription<dynamic>>[];

    Future<void> emitSummary() async {
      if (controller.isClosed) return;
      try {
        final summary = await _readSummary();
        if (!controller.isClosed) controller.add(summary);
      } catch (error) {
        _logger.severe('Erro no dashboard: $error');
      }
    }

    controller = StreamController<DashboardSummary>(
      onListen: () {
        emitSummary();
        subscriptions.add(_localDb.select(_localDb.patientsLocal).watch().listen((_) => emitSummary()));
        subscriptions.add(_localDb.select(_localDb.appointmentsLocal).watch().listen((_) => emitSummary()));
        subscriptions.add(_localDb.select(_localDb.evolutionsLocal).watch().listen((_) => emitSummary()));
      },
      onCancel: () async {
        for (final s in subscriptions) await s.cancel();
        await controller.close();
      },
    );

    return controller.stream;
  }

  Future<DashboardSummary> _readSummary() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final patients = await _localDb.select(_localDb.patientsLocal).get();
    final appointmentRows = await _localDb.select(_localDb.appointmentsLocal).get();
    
    int agendamentosHoje = 0;
    for (final row in appointmentRows) {
      // Usa o safeParse para garantir que row.startTime seja interpretado corretamente
      final startTime = _safeParse(row.startTime);
      final bool isToday = !startTime.isBefore(startOfDay) && startTime.isBefore(endOfDay);
      
      if (isToday) {
        final status = row.status.toLowerCase();
        final bool isCancelled = status == 'cancelled' || status == 'noshow' || status == 'missed';
        if (!isCancelled) {
          agendamentosHoje++;
        }
      }
    }

    final evolutionRows = await _localDb.select(_localDb.evolutionsLocal).get();
    final startOfMonth = DateTime(now.year, now.month);
    final startOfNextMonth = (now.month < 12) ? DateTime(now.year, now.month + 1) : DateTime(now.year + 1, 1);
    
    int attendanceThisMonth = 0;
    for (final row in evolutionRows) {
      final createdAt = _safeParse(row.createdAt);
      if (!createdAt.isBefore(startOfMonth) && createdAt.isBefore(startOfNextMonth)) {
        attendanceThisMonth++;
      }
    }

    return DashboardSummary(
      totalPacientes: patients.length,
      agendamentosHoje: agendamentosHoje,
      atendimentos: attendanceThisMonth,
    );
  }
}
