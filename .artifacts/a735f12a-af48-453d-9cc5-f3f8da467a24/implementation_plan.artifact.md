# Plano de Implementação — Ajustes DentalClinic

Este plano detalha as alterações para os 7 itens solicitados no sistema DentalClinic.

## User Review Required

> [!IMPORTANT]
> **Item 2 (Auditoria):** Proponho a criação de uma nova tabela `PatientChangeLog` dedicada para o histórico clínico, em vez de sobrecarregar a `LogAuditoria` (que é de sistema/LGPD). Isso facilita a exibição na ficha do paciente.
> **Item 4 (Capacidade):** A capacidade total será calculada como `(Horas de Funcionamento / 1h por consulta) * MaxCapacity` de cada clínica, a menos que uma regra diferente seja especificada.
> **Item 6 (Classificação):** Proponho adicionar o campo `ClinicalClassification` (Hígido/Satisfatório/Insatisfatório) na entidade `Patient` (ou `MedicalRecord`), representando o estado atual do paciente.

## Open Questions

> [!CAUTION]
> **Item 6:** Onde exatamente a classificação (Hígido/Satisfatório/Insatisfatório) deve ser armazenada?
> 1. Na **Evolução** (muda a cada atendimento)?
> 2. No **Cadastro do Paciente** (estado global atual)?
> 3. No **Odontograma**?
> *Minha recomendação: No Cadastro do Paciente ou em uma entidade de Resumo Clínico vinculada ao Prontuário.*

---

## Proposed Changes

### 1. Dashboard — Remoção de Atalhos [UI]

#### [MODIFY] [dashboard_screen.dart](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/lib/features/dashboard/presentation/views/dashboard_screen.dart)
- Remover a entrada "Clínicas" da lista retornada por `_getMenuItems`.
- Remover o widget `_buildQuickAction('Gestão de Clínicas', ...)` da seção "Acesso Rápido".

---

### 2. Auditoria de Pacientes [Backend + Database + Flutter]

#### [NEW] [PatientChangeLog.cs](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/backend/DentalClinic.Core/Domain/Entities/PatientChangeLog.cs)
- Entidade: `Id`, `PatientId`, `UserId`, `UserName`, `Timestamp`, `DuplaResponsavel`, `ChangesJson` (diff de campos).

#### [MODIFY] [PatientsController.cs](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/backend/DentalClinic.Api/Controllers/PatientsController.cs)
- Adicionar `DuplaResponsavel` ao DTO de Update.
- Implementar lógica de diff antes de salvar e persistir em `PatientChangeLog`.
- Adicionar endpoint `GET /api/patients/{id}/history`.

#### [MODIFY] [Patient.cs](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/backend/DentalClinic.Core/Domain/Entities/Patient.cs)
- (Opcional) Adicionar navegação para `ChangeLogs`.

---

### 3. Horários Reais de Atendimento [Backend + Database + Flutter]

#### [MODIFY] [Appointment.cs](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/backend/DentalClinic.Core/Domain/Entities/Appointment.cs)
- Adicionar campos: `ArrivalTime` (DateTime?), `ActualStartTime` (DateTime?), `ActualEndTime` (DateTime?).
- Adicionar métodos: `MarkArrival()`, `StartAt(DateTime time)`, `FinishAt(DateTime time)`.

#### [MODIFY] [AppointmentsController.cs](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/backend/DentalClinic.Api/Controllers/AppointmentsController.cs)
- Novos endpoints `PATCH`: `/status/arrival`, `/status/start`, `/status/finish`.

#### [MODIFY] [agenda_screen.dart](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/lib/features/agenda/presentation/views/agenda_screen.dart)
- Adicionar ações no card de agendamento para marcar chegada/início/fim.
- Exibir atraso calculado: `ArrivalTime - StartTime` (se > 0).

---

### 4. Estatísticas Reais no Dashboard [Backend + Flutter]

#### [MODIFY] [DashboardController.cs](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/backend/DentalClinic.Api/Controllers/DashboardController.cs)
- Substituir mocks por `Count` reais:
    - `ProceduresThisMonth`: `TreatmentItems` onde `Status == Completed` no mês atual.
    - `PendingAlerts`: Pacientes com `Anamnese` indicando alergia.
- Adicionar `TotalCapacity` vs `BookedSlots`.

#### [MODIFY] [dashboard_stats_model.dart](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/lib/features/dashboard/domain/models/dashboard_stats_model.dart)
- Atualizar modelo para receber novos campos.

---

### 5. Relatórios Semestrais [Flutter]

#### [MODIFY] [reports_screen.dart](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/lib/features/reports/presentation/views/reports_screen.dart)
- Adicionar seletor de "Semestre" que define automaticamente `startDate` e `endDate`.

---

### 6. Classificação Clínica [Backend + Database + Flutter]

#### [MODIFY] [Patient.cs](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/backend/DentalClinic.Core/Domain/Entities/Patient.cs)
- Adicionar `ClinicalClassification` (Enum: Healthy, Satisfactory, Unsatisfactory).

#### [MODIFY] [prontuario_screen.dart](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/lib/features/prontuario/presentation/views/prontuario_screen.dart)
- Adicionar seletor visual para a classificação.

---

### 7. Alertas de Saúde [Flutter]

#### [MODIFY] [prontuario_screen.dart](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/lib/features/prontuario/presentation/views/prontuario_screen.dart)
- Ao carregar, verificar `Anamnese.RespostasJson`.
- Exibir `Banner` ou `Alert` se `alergia.sim == true`.

---

## Verification Plan

### Automated Tests
- `dotnet test` para verificar as regras de domínio de `Appointment` e `PatientChangeLog`.
- `flutter test` para verificar a lógica de parse do JSON da `Anamnese`.

### Manual Verification
- Acessar Dashboard e validar se "Gestão de Clínicas" sumiu.
- Editar um paciente e verificar se o log foi gerado no banco.
- Marcar chegada em uma consulta e ver o tempo de atraso.
- Filtrar relatórios por semestre.
