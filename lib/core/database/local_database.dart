import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'local_database.g.dart';

@DataClassName('PatientLocal')
class PatientsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text().withLength(min: 3, max: 255)();
  TextColumn get cpf => text().withLength(min: 11, max: 14)();
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

@DataClassName('ClinicLocal')
class ClinicsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get location => text().nullable()();
  IntColumn get capacity => integer().withDefault(const Constant(1))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
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
  TextColumn get localPath => text()();
  TextColumn get type => text()();
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

class AuditLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get resourceId => text()();
  TextColumn get action => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

class AnamneseLocal extends Table {
  TextColumn get patientId => text()();
  TextColumn get responsesJson => text()();
  DateTimeColumn get lastUpdated => dateTime()();
  @override
  Set<Column> get primaryKey => {patientId};
}

class AppointmentsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get patientName => text()();
  TextColumn get status => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  TextColumn get clinicId => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class EvolutionsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class TreatmentItemsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()();
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
  OdontogramLocal,
  AuditLocal,
  AnamneseLocal,
  AppointmentsLocal,
  EvolutionsLocal,
  TreatmentItemsLocal,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    // Usando NativeDatabase estável conforme protocolo FFI
    return NativeDatabase(file);
  });
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
