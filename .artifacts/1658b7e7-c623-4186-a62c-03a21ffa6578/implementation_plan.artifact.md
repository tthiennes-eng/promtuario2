# Sincronização de pacientes e Auditoria

Darei continuidade à correção dos bugs identificados na sincronização de pacientes e no registro de logs de auditoria.

## User Review Required

> [!IMPORTANT]
> Notei que alguns dos arquivos no repositório já apresentam partes das correções solicitadas (como o endpoint `Register` em `LogsController.cs`). No entanto, identifiquei disparidades críticas entre o modelo de domínio (`Patient.cs`) e a configuração do Entity Framework (`PatientConfiguration.cs`), além da necessidade de garantir que todas as regras do prompt sejam estritamente seguidas.

## Proposed Changes

### Backend - Core & Infrastructure

#### [MODIFY] [Patient.cs](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/backend/DentalClinic.Core/Domain/Entities/Patient.cs)
- Garantir que `Email` seja `string?` e não possua `[Required]`.
- Garantir que `Gender` tenha `[MaxLength(20)]`.

#### [MODIFY] [PatientConfiguration.cs](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/backend/DentalClinic.Infrastructure/Persistence/Configurations/PatientConfiguration.cs)
- Alterar `HasMaxLength(1)` para `HasMaxLength(20)` na propriedade `Gender` (mapeada como coluna `sexo`).
- Garantir que `Email` reflita a natureza opcional (já está configurado com `HasMaxLength(255)` e sem `IsRequired`).

#### [MODIFY] [PatientValidator.cs](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/backend/DentalClinic.Core/Application/Validators/PatientValidator.cs)
- Garantir que a validação de `Email` seja condicional usando `.When(...)`, permitindo valores nulos ou vazios vindos do Flutter.

#### [MODIFY] [LogsController.cs](file:///C:/Users/Thiago/AndroidStudioProjects/promtuario2/backend/DentalClinic.Api/Controllers/LogsController.cs)
- Garantir a presença do endpoint `POST /api/logs/register`.
- Ajustar os atributos de `[Authorize]` para que o acesso `Admin` seja restrito apenas ao `GET`, enquanto o `POST` (registro) seja acessível a qualquer usuário autenticado.
- Mapear `resourceId` para `UsuarioId` e `action` para `Acao`.

### Banco de Dados - Migrations

#### [NEW] Migration: `UpdateGenderMaxLengthAndFixPatientFields`
- Como a configuração de `MaxLength` do `Gender` foi alterada no EF, gerarei uma nova migration para atualizar o schema do banco de dados.

## Verification Plan

### Automated Tests
- Executar `dotnet build backend/DentalClinic.sln` para garantir a integridade da compilação.
- Verificar se a migration é gerada corretamente com `dotnet ef migrations add`.

### Manual Verification
- O usuário deve testar a sincronização offline no app Flutter e verificar se o erro 400 desapareceu.
- O usuário deve verificar se os logs de login/logout agora retornam 200 OK em vez de 404.
