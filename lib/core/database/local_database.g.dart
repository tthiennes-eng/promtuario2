// GENERATED CODE - STUB DE RECUPERAÇÃO PARA DESTRAVAR O BUILD NO WINDOWS
part of 'local_database.dart';

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  
  late final ClinicsLocal clinicsLocal = ClinicsLocal(this);
  late final PatientsLocal patientsLocal = PatientsLocal(this);
  late final UsersLocal usersLocal = UsersLocal(this);
  late final AttachmentsLocal attachmentsLocal = AttachmentsLocal(this);
  late final AuditLocal auditLocal = AuditLocal(this);
  late final OdontogramLocal odontogramLocal = OdontogramLocal(this);
  late final AnamneseLocal anamneseLocal = AnamneseLocal(this);
  late final WaitListLocal waitListLocal = WaitListLocal(this);
  late final AppointmentsLocal appointmentsLocal = AppointmentsLocal(this);
  late final EvolutionsLocal evolutionsLocal = EvolutionsLocal(this);
  late final TreatmentItemsLocal treatmentItemsLocal = TreatmentItemsLocal(this);

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => allSchemaEntities.whereType<TableInfo<Table, dynamic>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        clinicsLocal, patientsLocal, usersLocal, attachmentsLocal, auditLocal, 
        odontogramLocal, anamneseLocal, waitListLocal, appointmentsLocal, evolutionsLocal, treatmentItemsLocal
      ];
}

abstract class _StubCompanion<D> extends UpdateCompanion<D> implements Insertable<D> {
  const _StubCompanion();
  @override Map<String, Expression<Object>> toColumns(bool nullToAbsent) => {};
}

// Companions necessários para os Repositórios e SyncService
class PatientsLocalCompanion extends _StubCompanion<dynamic> {
  final Value<String> id; final Value<bool> isSynced;
  const PatientsLocalCompanion({this.id = const Value.absent(), this.isSynced = const Value.absent(), dynamic fullName, dynamic socialName, dynamic cpf, dynamic susNumber, dynamic birthDate, dynamic createdAt, dynamic email, dynamic phone, dynamic gender, dynamic lgpdConsent});
  static dynamic insert({required String id, required String fullName, required String cpf, required DateTime birthDate, required DateTime createdAt, dynamic socialName, dynamic susNumber, dynamic email, dynamic phone, dynamic gender, dynamic lgpdConsent, dynamic isSynced}) => null;
}

class AttachmentsLocalCompanion extends _StubCompanion<dynamic> {
  final Value<bool> isSynced;
  const AttachmentsLocalCompanion({this.isSynced = const Value.absent(), dynamic id, dynamic patientId, dynamic localPath, dynamic type, dynamic description, dynamic createdAt});
}

class AppointmentsLocalCompanion extends _StubCompanion<dynamic> {
  final Value<String> status; final Value<bool> isSynced;
  const AppointmentsLocalCompanion({this.status = const Value.absent(), this.isSynced = const Value.absent(), dynamic id, dynamic patientId, dynamic patientName, dynamic doctorId, dynamic doctorName, dynamic studentId, dynamic studentName, dynamic professorId, dynamic professorName, dynamic startTime, dynamic endTime, dynamic procedureName, dynamic notes, dynamic clinicId});
}

class UsersLocalCompanion extends _StubCompanion<dynamic> {
  static dynamic insert({required String id, required String name, required String email, required String role, dynamic isActive}) => null;
}

class WaitListLocalCompanion extends _StubCompanion<dynamic> {
  final Value<bool> isSynced;
  const WaitListLocalCompanion({this.isSynced = const Value.absent(), dynamic id, dynamic patientId, dynamic patientName, dynamic clinicId, dynamic priority, dynamic specialty, dynamic observation, dynamic createdAt});
  static dynamic insert({required String id, required String patientId, required String patientName, required String clinicId, required String priority, required String specialty, required DateTime createdAt, dynamic observation, dynamic isSynced}) => null;
}

class AuditLocalCompanion extends _StubCompanion<dynamic> {
  final Value<bool> isSynced;
  const AuditLocalCompanion({this.isSynced = const Value.absent(), dynamic id, dynamic resourceId, dynamic action, dynamic timestamp});
}

class OdontogramLocalCompanion extends _StubCompanion<dynamic> {
  const OdontogramLocalCompanion({dynamic patientId, dynamic dataJson, dynamic lastUpdated, dynamic isSynced});
}

class AnamneseLocalCompanion extends _StubCompanion<dynamic> {
  const AnamneseLocalCompanion({dynamic patientId, dynamic responsesJson, dynamic lastUpdated, dynamic isSynced});
}

class ClinicsLocalCompanion extends _StubCompanion<dynamic> {
  const ClinicsLocalCompanion({dynamic id, dynamic name, dynamic description, dynamic location, dynamic capacity, dynamic isActive, dynamic startHour, dynamic endHour, dynamic slotDurationMinutes, dynamic metadataJson});
}

// Data Classes (Rows)
class PatientLocalData {
  final String id; final String fullName; final String? socialName; final String cpf; final String? susNumber;
  final DateTime birthDate; final String? email; final String? phone; final String? gender; 
  final DateTime createdAt; final bool lgpdConsent; final bool isSynced;
  PatientLocalData({required this.id, required this.fullName, this.socialName, required this.cpf, this.susNumber, required this.birthDate, this.email, this.phone, this.gender, required this.createdAt, required this.lgpdConsent, required this.isSynced});
}
class ClinicLocalData {
  final String id; final String name; final String? description; final String? location; final int capacity; final bool isActive;
  ClinicLocalData({required this.id, required this.name, this.description, this.location, required this.capacity, required this.isActive});
}
