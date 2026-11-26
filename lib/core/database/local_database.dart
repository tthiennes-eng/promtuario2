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
  IntColumn get capacity => integer().withDefault(const Value(0))();
  BoolColumn get isActive => boolean().withDefault(const Value(true))();
  @override
  Set<Column> get primaryKey => {id};
}

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
  BoolColumn get lgpdConsent => boolean().withDefault(const Value(false))();
  BoolColumn get isSynced => boolean().withDefault(const Value(false))();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class UsersLocal extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get role => text()();
  BoolColumn get isActive => boolean().withDefault(const Value(true))();
  @override
  Set<Column> get primaryKey => {id};
}

class AttachmentsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get localPath => text()();
  TextColumn get type => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Value(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class AuditLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get resourceId => text()();
  TextColumn get action => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Value(false))();
}

class AppointmentsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get patientName => text()();
  TextColumn get doctorId => text().nullable()();
  TextColumn get startTime => dateTime()();
  TextColumn get endTime => dateTime()();
  TextColumn get status => text()();
  BoolColumn get isSynced => boolean().withDefault(const Value(false))();
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
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Value(false))();
  @override
  Set<Column> get primaryKey => {id};
}

// Outras tabelas de prontuário (Stubs para compatibilidade)
class OdontogramLocal extends Table {
  TextColumn get patientId => text()();
  TextColumn get dataJson => text()();
  @override
  Set<Column> get primaryKey => {patientId};
}

class AnamneseLocal extends Table {
  TextColumn get patientId => text()();
  TextColumn get responsesJson => text()();
  @override
  Set<Column> get primaryKey => {patientId};
}

class EvolutionsLocal extends Table {
  TextColumn get id => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class TreatmentItemsLocal extends Table {
  TextColumn get id => text()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  ClinicsLocal, PatientsLocal, UsersLocal, AttachmentsLocal, AuditLocal,
  AppointmentsLocal, WaitListLocal, OdontogramLocal, AnamneseLocal,
  EvolutionsLocal, TreatmentItemsLocal
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 1;
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
