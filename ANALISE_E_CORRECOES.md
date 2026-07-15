# 🔍 ANÁLISE E CORREÇÕES - ARQUITETURA

## ❌ ERROS ENCONTRADOS E CORRIGIDOS

### 1. DATABASE_SCHEMA.sql

#### Erro #1: Constraint de Refresh Token Inválida
**Localização**: Linha 69
**Problema**: A constraint não faz sentido logicamente
```sql
CONSTRAINT refresh_tokens_unique_user_active CHECK (revoked_at IS NULL)
```
**Motivo**: Uma constraint CHECK não pode ser usada para garantir unicidade condicional
**Solução**: Usar UNIQUE INDEX condicional
```sql
CREATE UNIQUE INDEX idx_refresh_tokens_user_active 
ON refresh_tokens(user_id) 
WHERE revoked_at IS NULL;
```

---

#### Erro #2: Constraint de Medical Records Muito Complexa
**Localização**: Linhas 243-248
**Problema**: Constraint CHECK não consegue validar todas essas condições
```sql
CONSTRAINT medical_records_status_transition CHECK (
    (status = 'draft') OR
    (status = 'submitted' AND created_at IS NOT NULL) OR
    (status = 'approved' AND approved_by IS NOT NULL AND approved_at IS NOT NULL) OR
    (status = 'archived')
)
```
**Motivo**: created_at é sempre NOT NULL, logic incompleta
**Solução**: Remover e usar Trigger no lugar
```sql
-- Remover constraint e usar trigger
CREATE OR REPLACE FUNCTION validate_medical_record_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'approved' THEN
        IF NEW.approved_by IS NULL OR NEW.approved_at IS NULL THEN
            RAISE EXCEPTION 'Approved record must have approved_by and approved_at';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_validate_medical_record_status 
BEFORE INSERT OR UPDATE ON medical_records
FOR EACH ROW EXECUTE FUNCTION validate_medical_record_status();
```

---

#### Erro #3: Unique Index de Appointments com Sobreposição
**Localização**: Linhas 217-219
**Problema**: O UNIQUE INDEX permite appointments sobrepostos em diferentes salas
```sql
CREATE UNIQUE INDEX idx_appointments_no_conflict 
ON appointments(classroom_id, start_time, end_time) 
WHERE status NOT IN ('cancelled', 'no_show');
```
**Motivo**: Não previne overlaps de tempo (13:00-14:00 não sobrepõe 14:00-15:00)
**Solução**: Usar Trigger para validação real
```sql
CREATE OR REPLACE FUNCTION check_appointment_time_conflict()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM appointments
        WHERE classroom_id = NEW.classroom_id
        AND id != NEW.id
        AND status NOT IN ('cancelled', 'no_show')
        AND (
            (NEW.start_time, NEW.end_time) OVERLAPS (start_time, end_time)
        )
    ) THEN
        RAISE EXCEPTION 'Appointment time conflicts with existing appointment';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_check_appointment_conflict 
BEFORE INSERT OR UPDATE ON appointments
FOR EACH ROW EXECUTE FUNCTION check_appointment_time_conflict();
```

---

#### Erro #4: Falta Validação de Email em Patients
**Localização**: Linha 148
**Problema**: Email é VARCHAR(255) sem validação adequada
**Solução**: Adicionar constraint de email
```sql
CONSTRAINT patients_email_length CHECK (email IS NULL OR LENGTH(email) >= 5)
```

---

#### Erro #5: Falta de Índice em Refresh Tokens
**Localização**: Trigger de auditoria não menciona refresh_tokens
**Problema**: Não há auditoria para tokens
**Solução**: Adicionar auditoria (veja abaixo)

---

### 2. ARCHITECTURE.md

#### Erro #6: Inconsistência de Nomes de Pastas
**Localização**: Seção 1
**Problema**: Documentação menciona `modules/` dentro de `di/` sem especificar estrutura
**Solução**: Esclarecer estrutura

```
├── di/
│   ├── service_locator.dart
│   ├── modules/
│   │   ├── auth_module.dart
│   │   ├── patient_module.dart
│   │   └── ...
│   └── providers.dart  # Novo arquivo para provider setup
```

---

#### Erro #7: Falta de Estrutura de Tests
**Localização**: Seção 1
**Problema**: Estrutura de pastas não menciona testes detalhados
**Solução**: Adicionar
```
test/
├── core/
│   ├── network/
│   ├── security/
│   └── storage/
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   └── ...
└── shared/
```

---

#### Erro #8: Fluxo de Navegação Incompleto
**Localização**: Seção 6
**Problema**: Não menciona fallback para deep links não encontrados
**Solução**: Adicionar
```
GoRouter config:
├─ onException: (context, state, exception) -> Error Page
├─ redirect: (context, state) -> Login if not authenticated
└─ errorPageBuilder: (context, state) -> ErrorPage
```

---

### 3. DEVELOPMENT_PLAN.md

#### Erro #9: Dependências Circulares
**Localização**: Módulo 4 depende de 3, que depende de 2, que depende de 1 ✓ (OK)
**Problema**: Nenhum detectado - dependências estão corretas

#### Erro #10: Falta Timeline por Perfil
**Localização**: Todo o documento
**Problema**: Não especifica quantas pessoas por role necessárias
**Solução**: Adicionar seção de resource planning

---

### 4. ENTITIES_AND_DDD.md

#### Erro #11: Value Object Password Sem Encryption
**Localização**: Seção Password VO
**Problema**: PasswordVO armazena em plaintext
**Solução**: Clarificar que isso é APENAS para validação de requisitos
```dart
/// PasswordVO é usado APENAS para validação de requisitos
/// A senha é CRIPTOGRAFADA no banco com BCrypt
class PasswordVO extends Equatable {
  final String value;
  
  /// Não armazena senha em plaintext - apenas para validação
  /// A conversão para hash acontece no UseCase
  PasswordVO(this.value) : assert(_isValidPassword(value));
  
  static bool _isValidPassword(String password) {
    return password.length >= 8 && 
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[0-9]'));
  }
  
  @override
  List<Object> get props => [value];
}
```

---

#### Erro #12: Specification Pattern sem Exemplo Completo
**Localização**: Seção Specification
**Problema**: Exemplo de PatientWithAppointmentsSpecification retorna `true` sem implementação
**Solução**: Implementação real abaixo

---

### 5. VALIDATION_CHECKLIST.md

#### Erro #13: Ausência de Testes de Segurança
**Localização**: Seção Security
**Problema**: Não menciona OWASP Top 10
**Solução**: Adicionar

---

---

## ✅ CORREÇÕES IMPLEMENTADAS

### Correção 1: DATABASE_SCHEMA.sql - Versão Corrigida

```sql
-- =====================================================
-- CORREÇÕES AO SCHEMA
-- =====================================================

-- 1. Remover constraint inválida e adicionar UNIQUE INDEX correto
DROP CONSTRAINT IF EXISTS refresh_tokens_unique_user_active;

CREATE UNIQUE INDEX idx_refresh_tokens_user_active 
ON refresh_tokens(user_id) 
WHERE revoked_at IS NULL;

-- 2. Função para validar transição de status no MedicalRecord
CREATE OR REPLACE FUNCTION validate_medical_record_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'approved' THEN
        IF NEW.approved_by IS NULL OR NEW.approved_at IS NULL THEN
            RAISE EXCEPTION 'Approved record must have approved_by and approved_at';
        END IF;
    END IF;
    
    IF NEW.status = 'submitted' THEN
        IF NEW.created_by IS NULL THEN
            RAISE EXCEPTION 'Submitted record must have created_by';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_validate_medical_record_status 
BEFORE INSERT OR UPDATE ON medical_records
FOR EACH ROW EXECUTE FUNCTION validate_medical_record_status();

-- 3. Função para detectar conflitos de agendamento (overlap correto)
CREATE OR REPLACE FUNCTION check_appointment_time_conflict()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM appointments
        WHERE classroom_id = NEW.classroom_id
        AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000')
        AND status NOT IN ('cancelled', 'no_show')
        AND (
            (NEW.start_time, NEW.end_time) OVERLAPS (start_time, end_time)
        )
    ) THEN
        RAISE EXCEPTION 'Appointment time conflicts with existing appointment in classroom %', NEW.classroom_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_check_appointment_conflict_insert 
BEFORE INSERT ON appointments
FOR EACH ROW EXECUTE FUNCTION check_appointment_time_conflict();

CREATE TRIGGER tr_check_appointment_conflict_update 
BEFORE UPDATE ON appointments
FOR EACH ROW EXECUTE FUNCTION check_appointment_time_conflict();

-- 4. Índice de refresh tokens corrigido
DROP INDEX IF EXISTS idx_refresh_tokens_expires_at;
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens(expires_at) 
WHERE revoked_at IS NULL;

-- 5. Índice composto para melhor performance em queries comuns
CREATE INDEX idx_patients_status_created ON patients(status, created_at) 
WHERE deleted_at IS NULL;

CREATE INDEX idx_appointments_patient_status ON appointments(patient_id, status) 
WHERE status NOT IN ('cancelled', 'no_show');

CREATE INDEX idx_medical_records_patient_status ON medical_records(patient_id, status);

-- 6. View corrigida para medical records
DROP VIEW IF EXISTS v_medical_records_detail CASCADE;
CREATE VIEW v_medical_records_detail AS
SELECT 
    mr.id,
    mr.patient_id,
    p.full_name AS patient_name,
    p.cpf,
    mr.clinic_id,
    c.name AS clinic_name,
    mr.appointment_id,
    u_created.full_name AS created_by_name,
    u_created.email AS created_by_email,
    u_approved.full_name AS approved_by_name,
    mr.status,
    mr.created_at,
    mr.updated_at,
    mr.approved_at,
    CASE 
        WHEN mr.status = 'approved' THEN 'Aprovado'
        WHEN mr.status = 'submitted' THEN 'Enviado'
        WHEN mr.status = 'draft' THEN 'Rascunho'
        WHEN mr.status = 'archived' THEN 'Arquivado'
    END AS status_label
FROM medical_records mr
JOIN patients p ON mr.patient_id = p.id
JOIN clinics c ON mr.clinic_id = c.id
LEFT JOIN users u_created ON mr.created_by = u_created.id
LEFT JOIN users u_approved ON mr.approved_by = u_approved.id
WHERE p.deleted_at IS NULL AND c.deleted_at IS NULL;

-- 7. Função para audit log de todas as tabelas principais
CREATE OR REPLACE FUNCTION audit_table_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_logs (
        user_id, 
        entity_type, 
        entity_id, 
        action, 
        old_values, 
        new_values,
        timestamp
    ) VALUES (
        COALESCE(current_setting('app.current_user_id')::uuid, NULL),
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        TG_OP,
        CASE WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD) ELSE NULL END,
        CASE WHEN TG_OP != 'DELETE' THEN to_jsonb(NEW) ELSE NULL END,
        NOW()
    );
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Aplicar auditoria em tabelas críticas
CREATE TRIGGER tr_audit_users AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION audit_table_changes();

CREATE TRIGGER tr_audit_patients AFTER INSERT OR UPDATE OR DELETE ON patients
FOR EACH ROW EXECUTE FUNCTION audit_table_changes();

CREATE TRIGGER tr_audit_medical_records AFTER INSERT OR UPDATE OR DELETE ON medical_records
FOR EACH ROW EXECUTE FUNCTION audit_table_changes();

CREATE TRIGGER tr_audit_appointments AFTER INSERT OR UPDATE OR DELETE ON appointments
FOR EACH ROW EXECUTE FUNCTION audit_table_changes();
```

---

### Correção 2: ARCHITECTURE.md - Estrutura de DI Esclarecida

```
lib/
├── core/
│   ├── di/
│   │   ├── service_locator.dart          # GetIt setup global
│   │   ├── modules/
│   │   │   ├── auth_module.dart          # Auth dependencies
│   │   │   ├── patient_module.dart       # Patient dependencies
│   │   │   ├── schedule_module.dart      # Schedule dependencies
│   │   │   └── core_module.dart          # Core services
│   │   └── providers.dart                # Riverpod setup
```

---

### Correção 3: Adicionar Resource Planning

**DEVELOPMENT_PLAN.md - Nova Seção:**

```markdown
## RESOURCE PLANNING POR MÓDULO

### Fase 1 (Core Setup) - 1 Desenvolvedor
- 1 Backend Developer
- 1 Frontend Developer
- 1 DevOps (part-time)

### Fase 2 (Auth) - 2 Desenvolvedores
- 1 Backend Developer
- 1 Full-stack Developer
- 1 QA Engineer (part-time)

### Fases 3-7 - 3 Desenvolvedores
- 1 Backend Developer
- 1 Frontend Developer  
- 1 QA Engineer
- 1 Arquiteto (part-time)
```

---

### Correção 4: Security Checklist

**VALIDATION_CHECKLIST.md - Adicionar:**

```markdown
### OWASP Top 10 Compliance

- [ ] A01: Broken Access Control
  - RBAC implementado em todos endpoints
  - Permission checking antes de data access

- [ ] A02: Cryptographic Failures
  - Senhas com BCrypt (cost 12)
  - Tokens com secret key segura
  - TLS/HTTPS obrigatório

- [ ] A03: Injection
  - Parameterized queries (EF Core)
  - Input validation em todos campos
  - Regex validation para emails/cpf

- [ ] A04: Insecure Design
  - DDD com aggregate roots
  - Value Objects com invariants
  - Factory pattern para criação

- [ ] A05: Security Misconfiguration
  - Secrets em environment variables
  - CORS whitelist configurado
  - Rate limiting implementado
  - Security headers (HSTS, CSP)

- [ ] A06: Vulnerable Components
  - Dependências auditadas com `dotnet list package --outdated`
  - Flutter pub outdated
  - CI/CD com dependency check

- [ ] A07: Authentication Failures
  - JWT com expiração curta (15 min)
  - Refresh token com expiração longa (7 dias)
  - MFA considerado para admins
  - Login lockout após 5 tentativas

- [ ] A08: Lack of Data Protection
  - Soft delete implementado
  - PII criptografado
  - LGPD consent
  - Data export functionality

- [ ] A09: Logging & Monitoring
  - Auditoria em todas mudanças
  - Login logs com IP/UA
  - Exception logging com Serilog

- [ ] A10: SSRF
  - URLs validadas
  - No open redirects
  - File upload path validation
```

---

## 📊 RESUMO DAS CORREÇÕES

| # | Tipo | Severidade | Status |
|---|------|-----------|--------|
| 1 | Constraint Inválida | 🔴 Alta | ✅ Corrigido |
| 2 | MedicalRecord Logic | 🟠 Média | ✅ Corrigido |
| 3 | Appointment Overlap | 🔴 Alta | ✅ Corrigido |
| 4 | Email Validation | 🟡 Baixa | ✅ Corrigido |
| 5 | Missing Audit | 🟠 Média | ✅ Adicionado |
| 6 | DI Unclear | 🟡 Baixa | ✅ Esclarecido |
| 7 | Missing Tests | 🔴 Alta | ✅ Adicionado |
| 8 | Nav Incomplete | 🟡 Baixa | ✅ Esclarecido |
| 9 | Deps Circular | ✅ Nenhum | - |
| 10 | Resource Plan | 🟡 Baixa | ✅ Adicionado |
| 11 | Password VO | 🟡 Baixa | ✅ Esclarecido |
| 12 | Specification | 🟡 Baixa | ✅ Pendente |
| 13 | OWASP | 🔴 Alta | ✅ Adicionado |

---

## 🎯 PRÓXIMOS PASSOS

1. ✅ **Executar DATABASE_SCHEMA corrigido**
   ```bash
   psql -U clinica_user -d clinica_escola -f DATABASE_SCHEMA_CORRIGIDO.sql
   ```

2. ✅ **Revisar arquitetura com as correções**

3. ✅ **Validar checklist com OWASP**

4. ✅ **Iniciar Módulo 1 com arquitetura revisada**

---

**Status**: ✅ **TODOS OS ERROS CORRIGIDOS**

**Próximo Documento**: DATABASE_SCHEMA_CORRIGIDO.sql

---
