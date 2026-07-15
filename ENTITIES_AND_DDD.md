# ENTIDADES E DOMAIN-DRIVEN DESIGN

## AGREGADOS PRINCIPAIS

### 1. AGREGADO: USER (Usuário)

**Root Entity**: UserEntity
**Localização**: `domain/entities/user_entity.dart`

#### UserEntity
```dart
class UserEntity extends Equatable {
  final String id;
  final EmailVO email;
  final String fullName;
  final String? cpf;
  final String? phone;
  final UserRoleVO role;
  final UserStatusVO status;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.cpf,
    this.phone,
    required this.role,
    required this.status,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id, email, fullName, cpf, phone, role, status,
    lastLogin, createdAt, updatedAt, deletedAt
  ];
}
```

#### Value Objects
- **EmailVO** - Email com validação de formato
- **PasswordVO** - Password com validação de força
- **UserRoleVO** - Enum: admin, coordinator, professor, student, receptionist, secretary
- **UserStatusVO** - Enum: active, inactive, suspended, deleted
- **CPF_VO** - CPF com validação de dígitos

#### Métodos de Domínio
```dart
// Métodos que encapsulam lógica de negócio
class UserDomainService {
  // Validar senha com critérios mínimos
  bool isPasswordStrong(String password) { }
  
  // Verificar se usuário pode executar ação
  bool canPerformAction(UserEntity user, String action) { }
  
  // Verificar se usuário está bloqueado por tentativas falhadas
  bool isAccountLocked(UserEntity user) { }
}
```

---

### 2. AGREGADO: PATIENT (Paciente)

**Root Entity**: PatientEntity
**Localização**: `domain/entities/patient_entity.dart`

#### PatientEntity
```dart
class PatientEntity extends Equatable {
  final String id;
  final String cpf;
  final String fullName;
  final DateTime dateOfBirth;
  final String? gender;
  final EmailVO? email;
  final String? phone;
  final String? motherName;
  final String? responsibleId;
  final AddressVO? address;
  final PatientStatusVO status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const PatientEntity({
    required this.id,
    required this.cpf,
    required this.fullName,
    required this.dateOfBirth,
    this.gender,
    this.email,
    this.phone,
    this.motherName,
    this.responsibleId,
    this.address,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id, cpf, fullName, dateOfBirth, gender, email, phone,
    motherName, responsibleId, address, status, createdAt,
    updatedAt, deletedAt
  ];
}
```

#### Value Objects
- **AddressVO** - Logradouro, número, complemento, cidade, estado, CEP
- **PatientStatusVO** - Enum: active, inactive, deleted
- **DateOfBirthVO** - Data com validação de idade mínima

#### Métodos de Domínio
```dart
class PatientDomainService {
  // Calcular idade do paciente
  int calculateAge(PatientEntity patient) { }
  
  // Validar CPF
  bool isValidCPF(String cpf) { }
  
  // Verificar se paciente pode agendar
  bool canScheduleAppointment(PatientEntity patient) { }
}
```

---

### 3. AGREGADO: APPOINTMENT (Agendamento)

**Root Entity**: AppointmentEntity
**Child Entities**: Nenhuma (é simples)
**Localização**: `domain/entities/appointment_entity.dart`

#### AppointmentEntity
```dart
class AppointmentEntity extends Equatable {
  final String id;
  final String clinicId;
  final String classroomId;
  final String patientId;
  final String? professorId;
  final String? studentId;
  final String procedureId;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatusVO status;
  final String? notes;
  final DateTime? confirmedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppointmentEntity({
    required this.id,
    required this.clinicId,
    required this.classroomId,
    required this.patientId,
    this.professorId,
    this.studentId,
    required this.procedureId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    this.confirmedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, clinicId, classroomId, patientId, professorId, studentId,
    procedureId, startTime, endTime, status, notes, confirmedAt,
    createdAt, updatedAt
  ];
}
```

#### Value Objects
- **AppointmentStatusVO** - Enum: scheduled, confirmed, completed, cancelled, no_show
- **TimeRangeVO** - startTime e endTime com validação de ordem

#### Métodos de Domínio
```dart
class AppointmentDomainService {
  // Validar se horários não conflitam
  bool hasConflict(AppointmentEntity app1, AppointmentEntity app2) { }
  
  // Verificar se pode cancelar agendamento
  bool canBeCancelled(AppointmentEntity appointment) { }
  
  // Verificar se pode ser remarcado
  bool canBeRescheduled(AppointmentEntity appointment) { }
  
  // Calcular duração total
  Duration calculateDuration(AppointmentEntity appointment) { }
}
```

---

### 4. AGREGADO: MEDICAL RECORD (Prontuário)

**Root Entity**: MedicalRecordEntity
**Child Entities**: OdontogramEntity (pode estar relacionada)
**Localização**: `domain/entities/medical_record_entity.dart`

#### MedicalRecordEntity
```dart
class MedicalRecordEntity extends Equatable {
  final String id;
  final String patientId;
  final String clinicId;
  final String? appointmentId;
  final String createdBy;
  final String? approvedBy;
  final String? anamnesis;
  final String? clinicalExamination;
  final String? diagnosis;
  final String? treatmentPlan;
  final String? evolutionNotes;
  final String? professorSignature;
  final MedicalRecordStatusVO status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;

  const MedicalRecordEntity({
    required this.id,
    required this.patientId,
    required this.clinicId,
    this.appointmentId,
    required this.createdBy,
    this.approvedBy,
    this.anamnesis,
    this.clinicalExamination,
    this.diagnosis,
    this.treatmentPlan,
    this.evolutionNotes,
    this.professorSignature,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
  });

  @override
  List<Object?> get props => [
    id, patientId, clinicId, appointmentId, createdBy, approvedBy,
    anamnesis, clinicalExamination, diagnosis, treatmentPlan,
    evolutionNotes, professorSignature, status, createdAt,
    updatedAt, approvedAt
  ];
}
```

#### Value Objects
- **MedicalRecordStatusVO** - Enum: draft, submitted, approved, archived
- **ProfessorSignatureVO** - Assinatura do professor com timestamp

#### Métodos de Domínio
```dart
class MedicalRecordDomainService {
  // Validar se pode ser submetido
  bool canBeSubmitted(MedicalRecordEntity record) { }
  
  // Validar se pode ser aprovado
  bool canBeApproved(MedicalRecordEntity record) { }
  
  // Validar se tem todos campos obrigatórios preenchidos
  bool isComplete(MedicalRecordEntity record) { }
  
  // Gerar numero sequencial do prontuário
  String generateRecordNumber(String patientId, DateTime date) { }
}
```

---

### 5. AGREGADO: ODONTOGRAM (Odontograma)

**Root Entity**: OdontogramEntity
**Child Entities**: ToothDataVO (part of aggregate)
**Localização**: `domain/entities/odontogram_entity.dart`

#### OdontogramEntity
```dart
class OdontogramEntity extends Equatable {
  final String id;
  final String medicalRecordId;
  final String patientId;
  final List<ToothData> teeth; // 32 dentes (ISO 1992)
  final OdontogramStatusVO status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OdontogramEntity({
    required this.id,
    required this.medicalRecordId,
    required this.patientId,
    required this.teeth,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, medicalRecordId, patientId, teeth, status, createdAt, updatedAt
  ];
}
```

#### Value Objects
```dart
class ToothData extends Equatable {
  final int toothNumber; // 1-32 (ISO 1992)
  final ToothConditionVO condition;
  final List<ToothFaceVO> faces; // mesial, distal, oclusal, lingual
  final String? procedure;
  final DateTime? lastUpdated;

  const ToothData({
    required this.toothNumber,
    required this.condition,
    required this.faces,
    this.procedure,
    this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    toothNumber, condition, faces, procedure, lastUpdated
  ];
}

class ToothConditionVO extends Equatable {
  final String value; // healthy, cavity, treated, extracted, implant, prosthesis

  ToothConditionVO(this.value) : assert(_isValid(value));

  static bool _isValid(String value) =>
      ['healthy', 'cavity', 'treated', 'extracted', 'implant', 'prosthesis']
          .contains(value);

  @override
  List<Object> get props => [value];
}

class ToothFaceVO extends Equatable {
  final String face; // mesial, distal, oclusal, lingual
  final String status; // healthy, affected, treated
  final String? color; // #RRGGBB

  const ToothFaceVO({
    required this.face,
    required this.status,
    this.color,
  });

  @override
  List<Object?> get props => [face, status, color];
}
```

#### Métodos de Domínio
```dart
class OdontogramDomainService {
  // Validar dente específico
  bool isValidToothNumber(int number) => number >= 1 && number <= 32;
  
  // Validar condição
  bool isValidCondition(String condition) { }
  
  // Calcular quantos dentes afetados
  int countAffectedTeeth(OdontogramEntity odontogram) { }
  
  // Gerar relatório visual
  Map<String, int> generateSummary(OdontogramEntity odontogram) { }
}
```

---

### 6. AGREGADO: PROCEDURE (Procedimento)

**Root Entity**: ProcedureEntity
**Localização**: `domain/entities/procedure_entity.dart`

#### ProcedureEntity
```dart
class ProcedureEntity extends Equatable {
  final String id;
  final String clinicId;
  final String name;
  final String? description;
  final int durationMinutes;
  final Decimal? cost;
  final String? specialty;
  final UserRoleVO? requiredRole;
  final String status; // active, inactive
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProcedureEntity({
    required this.id,
    required this.clinicId,
    required this.name,
    this.description,
    required this.durationMinutes,
    this.cost,
    this.specialty,
    this.requiredRole,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, clinicId, name, description, durationMinutes, cost,
    specialty, requiredRole, status, createdAt, updatedAt
  ];
}
```

---

### 7. AGREGADO: CLINIC (Clínica)

**Root Entity**: ClinicEntity
**Child Entities**: ClassroomEntity
**Localização**: `domain/entities/clinic_entity.dart`

#### ClinicEntity
```dart
class ClinicEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String code;
  final String? managerId;
  final String status;
  final List<ClassroomEntity> classrooms;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClinicEntity({
    required this.id,
    required this.name,
    this.description,
    required this.code,
    this.managerId,
    required this.status,
    this.classrooms = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, name, description, code, managerId, status,
    classrooms, createdAt, updatedAt
  ];
}
```

#### ClassroomEntity
```dart
class ClassroomEntity extends Equatable {
  final String id;
  final String clinicId;
  final String number;
  final String? description;
  final int capacity;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClassroomEntity({
    required this.id,
    required this.clinicId,
    required this.number,
    this.description,
    required this.capacity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, clinicId, number, description, capacity,
    status, createdAt, updatedAt
  ];
}
```

---

## SPECIFICATION PATTERN (Critérios)

Para implementar filtros complexos de forma reutilizável:

```dart
abstract class Specification<T> {
  bool isSatisfiedBy(T candidate);
  
  Specification<T> and(Specification<T> other) => 
      AndSpecification<T>(this, other);
  
  Specification<T> or(Specification<T> other) => 
      OrSpecification<T>(this, other);
  
  Specification<T> not() => NotSpecification<T>(this);
}

// Exemplos de uso
class ActivePatientSpecification extends Specification<PatientEntity> {
  @override
  bool isSatisfiedBy(PatientEntity candidate) =>
      candidate.status.value == 'active';
}

class PatientWithAppointmentsSpecification extends Specification<PatientEntity> {
  final int minimumAppointments;
  
  PatientWithAppointmentsSpecification(this.minimumAppointments);
  
  @override
  bool isSatisfiedBy(PatientEntity candidate) {
    // Implementação
    return true;
  }
}

// Uso:
final spec = ActivePatientSpecification()
    .and(PatientWithAppointmentsSpecification(1));
```

---

## REPOSITORY INTERFACES

```dart
// Domain Layer
abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getUserById(String id);
  Future<Either<Failure, UserEntity>> getUserByEmail(String email);
  Future<Either<Failure, List<UserEntity>>> getUsersByRole(String role);
  Future<Either<Failure, UserEntity>> createUser(UserEntity user, String password);
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user);
  Future<Either<Failure, void>> deleteUser(String id);
}

abstract class PatientRepository {
  Future<Either<Failure, PatientEntity>> getPatientById(String id);
  Future<Either<Failure, PatientEntity>> getPatientByCPF(String cpf);
  Future<Either<Failure, List<PatientEntity>>> getAllPatients({
    int page = 1,
    int pageSize = 20,
    String? searchTerm,
    Specification<PatientEntity>? specification,
  });
  Future<Either<Failure, PatientEntity>> createPatient(PatientEntity patient);
  Future<Either<Failure, PatientEntity>> updatePatient(PatientEntity patient);
  Future<Either<Failure, void>> deletePatient(String id);
}

abstract class AppointmentRepository {
  Future<Either<Failure, AppointmentEntity>> getAppointmentById(String id);
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByDate(
    DateTime date, {
    String? clinicId,
    String? classroomId,
  });
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByPatient(
    String patientId, {
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByProfessor(
    String professorId, {
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, AppointmentEntity>> createAppointment(
    AppointmentEntity appointment,
  );
  Future<Either<Failure, AppointmentEntity>> updateAppointment(
    AppointmentEntity appointment,
  );
  Future<Either<Failure, void>> cancelAppointment(String id, String reason);
}

abstract class MedicalRecordRepository {
  Future<Either<Failure, MedicalRecordEntity>> getMedicalRecordById(String id);
  Future<Either<Failure, List<MedicalRecordEntity>>> getMedicalRecordsByPatient(
    String patientId, {
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, MedicalRecordEntity>> createMedicalRecord(
    MedicalRecordEntity record,
  );
  Future<Either<Failure, MedicalRecordEntity>> updateMedicalRecord(
    MedicalRecordEntity record,
  );
  Future<Either<Failure, MedicalRecordEntity>> approveMedicalRecord(
    String id,
    String approvedBy,
    String signature,
  );
}
```

---

## EVENTOS DE DOMÍNIO

```dart
abstract class DomainEvent {
  DateTime get occurredOn;
}

class UserCreatedEvent implements DomainEvent {
  final String userId;
  final String email;
  final UserRoleVO role;
  final DateTime _occurredOn = DateTime.now();

  UserCreatedEvent({
    required this.userId,
    required this.email,
    required this.role,
  });

  @override
  DateTime get occurredOn => _occurredOn;
}

class AppointmentConfirmedEvent implements DomainEvent {
  final String appointmentId;
  final String patientId;
  final DateTime confirmedAt;
  final DateTime _occurredOn = DateTime.now();

  AppointmentConfirmedEvent({
    required this.appointmentId,
    required this.patientId,
    required this.confirmedAt,
  });

  @override
  DateTime get occurredOn => _occurredOn;
}

class MedicalRecordApprovedEvent implements DomainEvent {
  final String recordId;
  final String approvedBy;
  final String signature;
  final DateTime _occurredOn = DateTime.now();

  MedicalRecordApprovedEvent({
    required this.recordId,
    required this.approvedBy,
    required this.signature,
  });

  @override
  DateTime get occurredOn => _occurredOn;
}
```

---

## FACTORY PATTERN PARA CRIAÇÃO

```dart
// Entity Factory
class UserFactory {
  static UserEntity create({
    required String id,
    required EmailVO email,
    required String fullName,
    required UserRoleVO role,
    String? cpf,
    String? phone,
  }) {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName,
      cpf: cpf,
      phone: phone,
      role: role,
      status: UserStatusVO('active'),
      lastLogin: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedAt: null,
    );
  }

  static UserEntity fromDatabase(Map<String, dynamic> data) {
    return UserEntity(
      id: data['id'] as String,
      email: EmailVO(data['email'] as String),
      fullName: data['full_name'] as String,
      cpf: data['cpf'] as String?,
      phone: data['phone'] as String?,
      role: UserRoleVO(data['role'] as String),
      status: UserStatusVO(data['status'] as String),
      lastLogin: data['last_login'] as DateTime?,
      createdAt: data['created_at'] as DateTime,
      updatedAt: data['updated_at'] as DateTime,
      deletedAt: data['deleted_at'] as DateTime?,
    );
  }
}
```

---

## RESUMO ARQUITETURA EVENTOS

```
┌─────────────────────────────────┐
│      Domain Events              │
│  (UserCreated, Confirmed, etc)  │
└──────────────┬──────────────────┘
               │
         ┌─────▼─────┐
         │  Use Case │
         └─────┬─────┘
               │
┌──────────────▼──────────────┐
│  Domain Services            │
│  - Validations              │
│  - Business Logic           │
│  - Aggregate Operations     │
└──────────────┬──────────────┘
               │
┌──────────────▼──────────────┐
│  Repository (Interface)     │
│  - Persistence abstraction  │
└──────────────┬──────────────┘
               │
┌──────────────▼──────────────┐
│  Data Layer Implementation  │
│  - Database Access          │
└─────────────────────────────┘
```

---
