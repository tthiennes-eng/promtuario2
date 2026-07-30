import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'local_database.g.dart';

/// Tabela de Pacientes com suporte a endereços e sincronização.
class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text().withLength(min: 3, max: 255)();
  TextColumn get cpf => text().withLength(min: 11, max: 14)();
  DateTimeColumn get birthDate => dateTime()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get gender => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get lgpdConsent => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  // Colunas de endereço
  TextColumn get street => text().nullable()();
  TextColumn get number => text().nullable()();
  TextColumn get neighborhood => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get zipCode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de Usuários (Cache para seleção de profissionais offline).
class UsersLocal extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get role => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local de metadados de Anexos pendentes de upload.
class AttachmentsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get localPath => text()();
  TextColumn get type => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local de Odontograma (Estado dos dentes em JSON).
class OdontogramLocal extends Table {
  TextColumn get patientId => text()();
  TextColumn get dataJson => text()();
  DateTimeColumn get lastUpdated => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {patientId};
}

/// Tabela de Lista de Espera com suporte a sincronização.
class WaitListLocal extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get patientName => text()();
  TextColumn get clinicId => text()();
  TextColumn get priority => text()();
  TextColumn get specialty => text()();
  TextColumn get observation => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de Auditoria com suporte a sincronização.
class AuditLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get resourceId => text()();
  TextColumn get action => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

/// Cache local de Anamnese com suporte a sincronização.
class AnamneseLocal extends Table {
  TextColumn get patientId => text()();
  TextColumn get responsesJson => text()();
  DateTimeColumn get lastUpdated => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {patientId};
}

/// Tabela de Agendamentos com suporte a cache offline completo.
class AppointmentsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().withDefault(const Constant(''))();
  TextColumn get patientName => text()();
  TextColumn get doctorId => text().withDefault(const Constant(''))();
  TextColumn get doctorName => text().withDefault(const Constant(''))();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  TextColumn get status => text()();
  TextColumn get procedureName => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get clinicId => text().withDefault(const Constant(''))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de Evoluções Clínicas com suporte a sincronização e auditoria.
class EvolutionsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get studentId => text().nullable()();
  TextColumn get studentName => text().nullable()();
  TextColumn get professorId => text().nullable()();
  TextColumn get professorName => text().nullable()();
  TextColumn get description => text()();
  BoolColumn get isSignedByProfessor => boolean().withDefault(const Constant(false))();
  DateTimeColumn get signedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get clinicName => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Itens do Plano de Tratamento com suporte a sincronização.
class TreatmentItemsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()();
  TextColumn get procedureName => text()();
  IntColumn get toothNumber => integer().nullable()();
  TextColumn get status => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Patients,
  UsersLocal,
  AttachmentsLocal,
  OdontogramLocal,
  WaitListLocal,
  AuditLocal,
  AnamneseLocal,
  AppointmentsLocal,
  EvolutionsLocal,
  TreatmentItemsLocal
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1000; 

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 1000) {
            // Em desenvolvimento, recriamos as tabelas para garantir integridade acadêmica e remover erros de sintaxe
            for (final table in allTables) {
              await m.deleteTable(table.actualTableName);
            }
            await m.createAll();
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'odonto_clinic_v10.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

final databaseProvider = Provider((ref) => AppDatabase());
