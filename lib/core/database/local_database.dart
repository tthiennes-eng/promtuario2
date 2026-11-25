import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ATENÇÃO: As classes abaixo são STUBS para permitir a compilação inicial no Windows.
/// Elas serão ignoradas pelo build_runner assim que o arquivo .g.dart for gerado.

@DataClassName('ClinicLocal')
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
  @override Set<Column> get primaryKey => {id};
}

@DataClassName('PatientLocal')
class PatientsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text().withLength(min: 3, max: 255)();
  TextColumn get socialName => text().withLength(min: 1, max: 255).nullable()();
  TextColumn get cpf => text().withLength(min: 11, max: 14)();
  TextColumn get susNumber => text().withLength(min: 15, max: 15).nullable()();
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
  @override Set<Column> get primaryKey => {id};
}

class UsersLocal extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get role => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  @override Set<Column> get primaryKey => {id};
}

class AttachmentsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get localPath => text().nullable()();
  TextColumn get type => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  @override Set<Column> get primaryKey => {id};
}

class OdontogramLocal extends Table {
  TextColumn get patientId => text()();
  TextColumn get dataJson => text()();
  DateTimeColumn get lastUpdated => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  @override Set<Column> get primaryKey => {patientId};
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
  @override Set<Column> get primaryKey => {id};
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
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  @override Set<Column> get primaryKey => {patientId};
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
  @override Set<Column> get primaryKey => {id};
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
  @override Set<Column> get primaryKey => {id};
}

class TreatmentItemsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()();
  TextColumn get procedureName => text()();
  IntColumn get toothNumber => integer().nullable()();
  TextColumn get status => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  @override Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  ClinicsLocal, PatientsLocal, UsersLocal, AttachmentsLocal, OdontogramLocal,
  WaitListLocal, AuditLocal, AnamneseLocal, AppointmentsLocal, EvolutionsLocal, TreatmentItemsLocal,
])
class AppDatabase extends GeneratedDatabase {
  AppDatabase() : super(_openConnection());
  @override int get schemaVersion => 4;
  @override MigrationStrategy get migration => MigrationStrategy(onCreate: (m) => m.createAll());
  
  // Getters dinâmicos para suportar todos os repositórios sem o arquivo .g.dart
  dynamic get clinicsLocal => allTables.firstWhere((t) => t.actualTableName == 'clinics_local');
  dynamic get patientsLocal => allTables.firstWhere((t) => t.actualTableName == 'patients_local');
  dynamic get usersLocal => allTables.firstWhere((t) => t.actualTableName == 'users_local');
  dynamic get attachmentsLocal => allTables.firstWhere((t) => t.actualTableName == 'attachments_local');
  dynamic get odontogramLocal => allTables.firstWhere((t) => t.actualTableName == 'odontogram_local');
  dynamic get waitListLocal => allTables.firstWhere((t) => t.actualTableName == 'wait_list_local');
  dynamic get auditLocal => allTables.firstWhere((t) => t.actualTableName == 'audit_local');
  dynamic get anamneseLocal => allTables.firstWhere((t) => t.actualTableName == 'anamnese_local');
  dynamic get appointmentsLocal => allTables.firstWhere((t) => t.actualTableName == 'appointments_local');
  dynamic get evolutionsLocal => allTables.firstWhere((t) => t.actualTableName == 'evolutions_local');
  dynamic get treatmentItemsLocal => allTables.firstWhere((t) => t.actualTableName == 'treatment_items_local');
  
  @override
  Future<void> close() => super.close();
}

// -----------------------------------------------------------------------------------------
// STUBS DE COMPILAÇÃO - Impedem erros de "Undefined Name" nos repositórios.
// -----------------------------------------------------------------------------------------

class PatientsLocalCompanion {
  const PatientsLocalCompanion({dynamic id, dynamic fullName, dynamic socialName, dynamic cpf, dynamic susNumber, dynamic birthDate, dynamic createdAt, dynamic email, dynamic phone, dynamic gender, dynamic lgpdConsent, dynamic isSynced});
  static dynamic insert({dynamic id, dynamic fullName, dynamic socialName, dynamic cpf, dynamic susNumber, dynamic birthDate, dynamic createdAt, dynamic email, dynamic phone, dynamic gender, dynamic lgpdConsent, dynamic isSynced}) => null;
}

class AttachmentsLocalCompanion { const AttachmentsLocalCompanion({dynamic id, dynamic patientId, dynamic localPath, dynamic type, dynamic description, dynamic createdAt, dynamic isSynced}); }
class AppointmentsLocalCompanion { const AppointmentsLocalCompanion({dynamic id, dynamic patientId, dynamic patientName, dynamic doctorId, dynamic doctorName, dynamic studentId, dynamic studentName, dynamic professorId, dynamic professorName, dynamic startTime, dynamic endTime, dynamic status, dynamic procedureName, dynamic notes, dynamic clinicId, dynamic isSynced}); }
class UsersLocalCompanion { static dynamic insert({dynamic id, dynamic name, dynamic email, dynamic role, dynamic isActive}) => null; }
class AuditLocalCompanion { const AuditLocalCompanion({dynamic id, dynamic resourceId, dynamic action, dynamic timestamp, dynamic isSynced}); }
class WaitListLocalCompanion { 
  const WaitListLocalCompanion({dynamic id, dynamic patientId, dynamic patientName, dynamic clinicId, dynamic priority, dynamic specialty, dynamic observation, dynamic createdAt, dynamic isSynced}); 
  static dynamic insert({dynamic id, dynamic patientId, dynamic patientName, dynamic clinicId, dynamic priority, dynamic specialty, dynamic observation, dynamic createdAt, dynamic isSynced}) => null;
}
class OdontogramLocalCompanion { const OdontogramLocalCompanion({dynamic patientId, dynamic dataJson, dynamic lastUpdated, dynamic isSynced}); }
class AnamneseLocalCompanion { const AnamneseLocalCompanion({dynamic patientId, dynamic responsesJson, dynamic lastUpdated, dynamic isSynced}); }
class ClinicsLocalCompanion { const ClinicsLocalCompanion({dynamic id, dynamic name, dynamic description, dynamic location, dynamic capacity, dynamic isActive, dynamic startHour, dynamic endHour, dynamic slotDurationMinutes, dynamic metadataJson}); }

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
