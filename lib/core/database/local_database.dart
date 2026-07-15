import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'local_database.g.dart';

/// Tabela de Pacientes para cache local.
class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text().withLength(min: 3, max: 255)();
  TextColumn get cpf => text().withLength(min: 11, max: 14)();
  DateTimeColumn get birthDate => dateTime()();
  TextColumn get phone => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de Agendamentos para cache local (Agenda Offline).
class AppointmentsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get patientName => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  TextColumn get status => text()();
  TextColumn get procedureName => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Cache local de Evoluções Clínicas para suporte a áreas com sinal instável.
class EvolutionsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Armazenamento local de Itens do Plano de Tratamento para consulta offline.
class TreatmentItemsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()();
  TextColumn get procedureName => text()();
  RealColumn get value => real()();
  IntColumn get toothNumber => integer().nullable()();
  TextColumn get status => text()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Patients, AppointmentsLocal, EvolutionsLocal, TreatmentItemsLocal])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4; 

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(appointmentsLocal);
      if (from < 3) await m.createTable(evolutionsLocal);
      if (from < 4) await m.createTable(treatmentItemsLocal);
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'odonto_clinic_v1.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

final databaseProvider = Provider((ref) => AppDatabase());
