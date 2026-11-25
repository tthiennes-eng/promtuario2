part of 'local_database.dart';

// Stub de emergência para permitir a compilação no Windows
abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
}

class PatientsLocalCompanion {
  const PatientsLocalCompanion({dynamic id, dynamic isSynced});
  static dynamic insert({required String id, required String fullName, required String cpf, required DateTime birthDate, required DateTime createdAt, Value<String?> socialName = const Value.absent(), Value<String?> susNumber = const Value.absent(), Value<String?> email = const Value.absent(), Value<String?> phone = const Value.absent(), Value<String?> gender = const Value.absent(), Value<bool> lgpdConsent = const Value.absent(), Value<bool> isSynced = const Value.absent()}) => null;
}
class AttachmentsLocalCompanion { const AttachmentsLocalCompanion({dynamic isSynced}); }
class AppointmentsLocalCompanion { const AppointmentsLocalCompanion({dynamic status, dynamic isSynced, dynamic id, dynamic patientId, dynamic patientName, dynamic doctorId, dynamic doctorName, dynamic studentId, dynamic studentName, dynamic professorId, dynamic professorName, dynamic startTime, dynamic endTime, dynamic procedureName, dynamic notes, dynamic clinicId}); }
class WaitListLocalCompanion { 
  const WaitListLocalCompanion({dynamic isSynced}); 
  static dynamic insert({required String id, required String patientId, required String patientName, required String clinicId, required String priority, required String specialty, required DateTime createdAt, Value<String?> observation = const Value.absent(), Value<bool> isSynced = const Value.absent()}) => null;
}
class AuditLocalCompanion { const AuditLocalCompanion({dynamic resourceId, dynamic action, dynamic timestamp, dynamic isSynced}); }
class OdontogramLocalCompanion { const OdontogramLocalCompanion({dynamic patientId, dynamic dataJson, dynamic lastUpdated, dynamic isSynced}); }
class AnamneseLocalCompanion { const AnamneseLocalCompanion({dynamic patientId, dynamic responsesJson, dynamic lastUpdated, dynamic isSynced}); }
class ClinicsLocalCompanion { const ClinicsLocalCompanion({dynamic id, dynamic name, dynamic description, dynamic location, dynamic capacity, dynamic isActive, dynamic startHour, dynamic endHour, dynamic slotDurationMinutes, dynamic metadataJson}); }
