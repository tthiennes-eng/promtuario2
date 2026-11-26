import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'local_database.g.dart';

@DataClassName('ClinicLocalData')
class ClinicsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get location => text().nullable()();
  IntColumn get capacity => integer().withDefault(const Constant(1))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get startHour => integer().withDefault(const Constant(8))();
  IntColumn get endHour => integer().withDefault(const Constant(18))();
  IntColumn get slotDurationMinutes => integer().withDefault(const Constant(60))();
  TextColumn get metadataJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PatientLocalData')
class PatientsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text()();
  TextColumn get socialName => text().nullable()();
  TextColumn get cpf => text()();
  TextColumn get susNumber => text().nullable()();
  DateTimeColumn get birthDate => dateTime()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get gender => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get lgpdConsent => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get street => text().nullable()();
  TextColumn get number => text().nullable()();
  TextColumn get neighborhood => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get zipCode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UsersLocal extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get role => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class AttachmentsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get localPath => text().nullable()();
  TextColumn get type => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class AuditLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get resourceId => text()();
  TextColumn get action => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

class AppointmentsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().withDefault(const Constant(''))();
  TextColumn get patientName => text()();
  TextColumn get doctorId => text().withDefault(const Constant(''))();
  TextColumn get doctorName => text().withDefault(const Constant(''))();
  TextColumn get studentId => text().nullable()();
  TextColumn get studentName => text().nullable()();
  TextColumn get professorId => text().nullable()();
  TextColumn get professorName => text().nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  TextColumn get status => text()();
  TextColumn get procedureName => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get clinicId => text().withDefault(const Constant(''))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

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

class OdontogramLocal extends Table {
  TextColumn get patientId => text()();
  TextColumn get dataJson => text()();
  DateTimeColumn get lastUpdated => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {patientId};
}

class AnamneseLocal extends Table {
  TextColumn get patientId => text()();
  TextColumn get responsesJson => text()();
  DateTimeColumn get lastUpdated => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {patientId};
}

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

class TreatmentItemsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()();
  TextColumn get procedureName => text()();
  IntColumn get toothNumber => integer().nullable()();
  TextColumn get status => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  ClinicsLocal,
  PatientsLocal,
  UsersLocal,
  AttachmentsLocal,
  AuditLocal,
  AppointmentsLocal,
  WaitListLocal,
  OdontogramLocal,
  AnamneseLocal,
  EvolutionsLocal,
  TreatmentItemsLocal,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 6) {
        // Limpeza única do cache local de pacientes, agendamentos e registros vinculados.
        final tablesToClear = <TableInfo<Table, dynamic>>[
          patientsLocal,
          appointmentsLocal,
          waitListLocal,
          odontogramLocal,
          anamneseLocal,
          evolutionsLocal,
          attachmentsLocal,
          treatmentItemsLocal,
        ];
        for (final table in tablesToClear) {
          await migrator.deleteTable(table.actualTableName);
        }
      }
      await migrator.createAll();
      if (from < 7) {
        await customStatement(
          "DELETE FROM appointments_local WHERE patient_id IN (SELECT id FROM patients_local WHERE LOWER(full_name) LIKE '%testecadastro%') OR LOWER(patient_name) LIKE '%testecadastro%'",
        );
        await customStatement(
          "DELETE FROM wait_list_local WHERE patient_id IN (SELECT id FROM patients_local WHERE LOWER(full_name) LIKE '%testecadastro%') OR LOWER(patient_name) LIKE '%testecadastro%'",
        );
        await customStatement(
          "DELETE FROM patients_local WHERE LOWER(full_name) LIKE '%testecadastro%'",
        );
      }
    },
    beforeOpen: (details) async {
      final migrator = createMigrator();
      for (final table in allTables) {
        final rows = await customSelect(
          'PRAGMA table_info("${table.actualTableName}")',
        ).get();
        if (rows.isEmpty) {
          await migrator.createTable(table);
          continue;
        }
        final existingColumns = rows
            .map((row) => row.read<String>('name'))
            .toSet();
        final expectedColumns = table.$columns.map((c) => c.$name).toSet();
        if (!existingColumns.containsAll(expectedColumns)) {
          await migrator.deleteTable(table.actualTableName);
          await migrator.createTable(table);
        }
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
