# Walkthrough — Ajustes DentalClinic

Este documento resume as melhorias implementadas no sistema DentalClinic, abrangendo Dashboard, Auditoria, Agenda e Prontuário.

## Mudanças Realizadas

### 1. Dashboard — Limpeza de Menu
- Removido o atalho "Gestão de Clínicas" do menu lateral e da seção de Acesso Rápido para simplificar a interface conforme solicitado.

### 2. Auditoria Detalhada de Pacientes
- **Backend:** Criada a entidade `PatientChangeLog` e tabela correspondente para registrar quem alterou, data/hora, dupla responsável e o diff de campos (antes/depois) em formato JSON.
- **Backend:** Atualizado o `PatientsController.Update` para calcular automaticamente as mudanças e persistir o log.
- **Flutter:** Adicionada uma nova tela de "Histórico de Alterações" acessível pelo Prontuário, exibindo os cards de auditoria com os valores alterados destacados em vermelho/verde.

### 3. Gestão de Horários Reais
- **Backend:** Adicionados campos `ArrivalTime`, `ActualStartTime` e `ActualEndTime` na entidade `Appointment`.
- **Backend:** Criados endpoints dedicados para "Registrar Chegada", "Iniciar Atendimento" e "Finalizar Atendimento".
- **Flutter:** Atualizada a tela de Agenda para exibir o tempo de atraso (em minutos) quando houver demora. Adicionados botões de ação rápida no detalhe do agendamento.

### 4. Estatísticas Reais no Dashboard
- **Backend:** Substituídos os mocks por consultas reais ao banco de dados:
    - **Atendimentos:** Contagem de procedimentos finalizados no mês.
    - **Vagas/Ocupação:** Cálculo dinâmico baseado na capacidade das clínicas ativas vs. agendamentos feitos.
    - **Alertas:** Contagem de pacientes com alergias sinalizadas na anamnese.

### 5. Relatórios Semestrais
- **Flutter:** Adicionado um seletor de "Período Acadêmico" na tela de relatórios, permitindo filtrar rapidamente pelo 1º ou 2º semestre do ano, além do intervalo personalizado.

### 6. Classificação Clínica Geral
- **Backend:** Adicionado o enum `ClinicalClassification` (Hígido, Satisfatório, Insatisfatório) à entidade `Patient`.
- **Flutter:** Implementado um seletor de classificação diretamente no cabeçalho do Prontuário, permitindo que o profissional defina o estado global do paciente.

### 7. Alertas de Alergia
- **Flutter:** O Prontuário agora lê automaticamente o JSON de respostas da Anamnese. Caso haja registro de alergia (`sim: true`), um banner de alerta vermelho é exibido no topo da tela com a descrição da alergia.

---

## Verificação Realizada

- **Backend:** `dotnet build` executado com sucesso. Três novas migrations foram geradas:
    1. `AddPatientChangeLog`
    2. `UpdateAppointmentTimes`
    3. `AddPatientClassification`
- **Flutter:** `flutter analyze` validado. Corrigidos erros de argumentos obrigatórios nos modelos de estatísticas.
- **Geração de Código:** `dart run build_runner build` executado para atualizar todas as classes `freezed` e `json_serializable`.

## Observações Adicionais (Sugestões)
- **Desempenho:** O cálculo de `TotalCapacity` no `DashboardController` é feito em tempo de execução. Para escalas maiores, recomenda-se cachear esse valor ou persistir a capacidade agregada na entidade `Clinic`.
- **Depreciações:** Notou-se o uso de `withOpacity` e `MaterialStateProperty` no Flutter, que estão depreciados em versões recentes (3.22+). Recomenda-se migrar para `withValues()` e `WidgetStateProperty` futuramente.
