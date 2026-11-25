import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/core/providers/providers.dart';
import 'package:drift/drift.dart';

/// Coordena a sincronização de dados pendentes no banco local para o servidor.
class SyncService {
  SyncService(this._db, this._ref);

  final AppDatabase _db;
  final Ref _ref;
  final Logger _logger = Logger('SyncService');
  Timer? _syncTimer;
  bool _isSynchronizing = false;

  void startAutoSync() {
    _syncTimer?.cancel();
    unawaited(syncAll());
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) => unawaited(syncAll()));
  }

  Future<void> syncAll() async {
    if (_isSynchronizing) return;
    _isSynchronizing = true;
    try {
      _logger.info('Iniciando sincronização...');
      await _syncClinics();
      await _syncPatients();
      await _syncAppointments();
      await _syncWaitList();
      await _syncProntuario();
      await _syncAttachments();
      await _syncAuditLogs();
    } finally {
      _isSynchronizing = false;
    }
  }

  Future<void> _syncClinics() => _run('clínicas', () => _ref.read(proceduresRepositoryProvider).syncClinics());
  Future<void> _syncPatients() => _run('pacientes', () => _ref.read(patientRepositoryProvider).syncPatients());
  Future<void> _syncAppointments() => _run('agendamentos', () => _ref.read(appointmentRepositoryProvider).syncAppointments());
  Future<void> _syncWaitList() => _run('lista de espera', () => _ref.read(waitListRepositoryProvider).syncWaitList());
  Future<void> _syncProntuario() => _run('prontuário', () => _ref.read(prontuarioRepositoryProvider).syncPendingData());

  Future<void> _syncAttachments() async {
    try {
      final pending = await (_db.select(_db.attachmentsLocal)..where((t) => t.isSynced.equals(false))).get();
      final repository = _ref.read(attachmentRepositoryProvider);
      
      for (final attachment in pending) {
        final sent = await repository.syncPendingAttachment(attachment.id);
        if (sent) {
          await (_db.update(_db.attachmentsLocal)..where((t) => t.id.equals(attachment.id)))
              .write(AttachmentsLocalCompanion(isSynced: Value(true))); // CORRIGIDO: Removido const
        }
      }
    } catch (e) {
      _logger.warning('Erro ao sincronizar anexos: $e');
    }
  }

  Future<void> _syncAuditLogs() async {
    try {
      final pending = await (_db.select(_db.auditLocal)..where((t) => t.isSynced.equals(false))).get();
      final repository = _ref.read(auditRepositoryProvider);
      for (final log in pending) {
        final sent = await repository.syncPendingAccess(log.resourceId, log.action);
        if (sent) {
          await (_db.delete(_db.auditLocal)..where((t) => t.id.equals(log.id))).go();
        }
      }
    } catch (e) {
      _logger.warning('Erro na auditoria: $e');
    }
  }

  Future<void> _run(String scope, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      _logger.warning('Falha em $scope: $e');
    }
  }

  void stop() => _syncTimer?.cancel();
}

final syncServiceProvider = Provider((ref) => SyncService(ref.watch(databaseProvider), ref));
