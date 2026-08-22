using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace DentalClinic.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPatientChangeLogAndAppointmentTimes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_agendamentos_usuarios_UserId",
                table: "agendamentos");

            migrationBuilder.DropForeignKey(
                name: "FK_anamneses_pacientes_PatientId",
                table: "anamneses");

            migrationBuilder.DropForeignKey(
                name: "FK_anamneses_usuarios_CriadoPorId",
                table: "anamneses");

            migrationBuilder.DropForeignKey(
                name: "FK_Attachments_MedicalRecords_MedicalRecordId",
                table: "Attachments");

            migrationBuilder.DropForeignKey(
                name: "FK_Attachments_usuarios_UserId",
                table: "Attachments");

            migrationBuilder.DropForeignKey(
                name: "FK_evolucoes_clinicas_MedicalRecords_MedicalRecordId",
                table: "evolucoes_clinicas");

            migrationBuilder.DropForeignKey(
                name: "FK_evolucoes_clinicas_clinicas_ClinicId",
                table: "evolucoes_clinicas");

            migrationBuilder.DropForeignKey(
                name: "FK_evolucoes_clinicas_pacientes_PatientId",
                table: "evolucoes_clinicas");

            migrationBuilder.DropForeignKey(
                name: "FK_evolucoes_clinicas_usuarios_ProfessorId",
                table: "evolucoes_clinicas");

            migrationBuilder.DropForeignKey(
                name: "FK_evolucoes_clinicas_usuarios_StudentId",
                table: "evolucoes_clinicas");

            migrationBuilder.DropForeignKey(
                name: "FK_evolucoes_clinicas_usuarios_UserId",
                table: "evolucoes_clinicas");

            migrationBuilder.DropForeignKey(
                name: "FK_lista_espera_clinicas_ClinicId",
                table: "lista_espera");

            migrationBuilder.DropForeignKey(
                name: "FK_lista_espera_pacientes_PatientId",
                table: "lista_espera");

            migrationBuilder.DropForeignKey(
                name: "FK_odontogramas_pacientes_PatientId",
                table: "odontogramas");

            migrationBuilder.DropForeignKey(
                name: "FK_TreatmentItems_MedicalRecords_MedicalRecordId",
                table: "TreatmentItems");

            migrationBuilder.DropIndex(
                name: "IX_TreatmentItems_MedicalRecordId",
                table: "TreatmentItems");

            migrationBuilder.DropIndex(
                name: "IX_pacientes_Name",
                table: "pacientes");

            migrationBuilder.DropIndex(
                name: "IX_odontogramas_UpdatedAt",
                table: "odontogramas");

            migrationBuilder.DropIndex(
                name: "IX_lista_espera_IsResolved",
                table: "lista_espera");

            migrationBuilder.DropIndex(
                name: "IX_Attachments_MedicalRecordId",
                table: "Attachments");

            migrationBuilder.DropIndex(
                name: "IX_Attachments_UserId",
                table: "Attachments");

            migrationBuilder.DropIndex(
                name: "IX_agendamentos_UserId",
                table: "agendamentos");

            migrationBuilder.DropPrimaryKey(
                name: "PK_LogsAuditoria",
                table: "LogsAuditoria");

            migrationBuilder.DropPrimaryKey(
                name: "PK_evolucoes_clinicas",
                table: "evolucoes_clinicas");

            migrationBuilder.DropIndex(
                name: "IX_evolucoes_clinicas_CreatedAt",
                table: "evolucoes_clinicas");

            migrationBuilder.DropIndex(
                name: "IX_evolucoes_clinicas_MedicalRecordId",
                table: "evolucoes_clinicas");

            migrationBuilder.DropIndex(
                name: "IX_evolucoes_clinicas_UserId",
                table: "evolucoes_clinicas");

            migrationBuilder.DropColumn(
                name: "Address_Complement",
                table: "usuarios");

            migrationBuilder.DropColumn(
                name: "Role",
                table: "usuarios");

            migrationBuilder.DropColumn(
                name: "Status",
                table: "usuarios");

            migrationBuilder.DropColumn(
                name: "endereco_bairro",
                table: "usuarios");

            migrationBuilder.DropColumn(
                name: "endereco_cep",
                table: "usuarios");

            migrationBuilder.DropColumn(
                name: "endereco_cidade",
                table: "usuarios");

            migrationBuilder.DropColumn(
                name: "endereco_estado",
                table: "usuarios");

            migrationBuilder.DropColumn(
                name: "endereco_numero",
                table: "usuarios");

            migrationBuilder.DropColumn(
                name: "endereco_rua",
                table: "usuarios");

            migrationBuilder.DropColumn(
                name: "MedicalRecordId",
                table: "TreatmentItems");

            migrationBuilder.DropColumn(
                name: "Allergies",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "AlternatePhone",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "City",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "MedicalHistory",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "Medications",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "Name",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "Neighborhood",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "RG",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "ResponsibleName",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "ResponsiblePhone",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "State",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "ZipCode",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "Anamnesis",
                table: "MedicalRecords");

            migrationBuilder.DropColumn(
                name: "ClinicalExam",
                table: "MedicalRecords");

            migrationBuilder.DropColumn(
                name: "Diagnosis",
                table: "MedicalRecords");

            migrationBuilder.DropColumn(
                name: "TreatmentPlan",
                table: "MedicalRecords");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "MedicalRecords");

            migrationBuilder.DropColumn(
                name: "Address_Complement",
                table: "clinicas");

            migrationBuilder.DropColumn(
                name: "ClosingTime",
                table: "clinicas");

            migrationBuilder.DropColumn(
                name: "CoordinatorUserId",
                table: "clinicas");

            migrationBuilder.DropColumn(
                name: "MaxCapacity",
                table: "clinicas");

            migrationBuilder.DropColumn(
                name: "OpeningTime",
                table: "clinicas");

            migrationBuilder.DropColumn(
                name: "endereco_bairro",
                table: "clinicas");

            migrationBuilder.DropColumn(
                name: "endereco_cep",
                table: "clinicas");

            migrationBuilder.DropColumn(
                name: "endereco_cidade",
                table: "clinicas");

            migrationBuilder.DropColumn(
                name: "endereco_estado",
                table: "clinicas");

            migrationBuilder.DropColumn(
                name: "endereco_numero",
                table: "clinicas");

            migrationBuilder.DropColumn(
                name: "endereco_rua",
                table: "clinicas");

            migrationBuilder.DropColumn(
                name: "UserId",
                table: "Attachments");

            migrationBuilder.DropColumn(
                name: "UserId",
                table: "agendamentos");

            migrationBuilder.DropColumn(
                name: "DadosAntigos",
                table: "LogsAuditoria");

            migrationBuilder.DropColumn(
                name: "DadosNovos",
                table: "LogsAuditoria");

            migrationBuilder.DropColumn(
                name: "IpOrigem",
                table: "LogsAuditoria");

            migrationBuilder.DropColumn(
                name: "Tabela",
                table: "LogsAuditoria");

            migrationBuilder.DropColumn(
                name: "Usuario",
                table: "LogsAuditoria");

            migrationBuilder.DropColumn(
                name: "MedicalRecordId",
                table: "evolucoes_clinicas");

            migrationBuilder.DropColumn(
                name: "SignedAt",
                table: "evolucoes_clinicas");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "evolucoes_clinicas");

            migrationBuilder.DropColumn(
                name: "UserId",
                table: "evolucoes_clinicas");

            migrationBuilder.RenameTable(
                name: "LogsAuditoria",
                newName: "logs_auditoria");

            migrationBuilder.RenameTable(
                name: "evolucoes_clinicas",
                newName: "evolucoes");

            migrationBuilder.RenameColumn(
                name: "Id",
                table: "usuarios",
                newName: "id");

            migrationBuilder.RenameColumn(
                name: "UpdatedAt",
                table: "usuarios",
                newName: "atualizado_em");

            migrationBuilder.RenameColumn(
                name: "Roles",
                table: "usuarios",
                newName: "perfis_json");

            migrationBuilder.RenameColumn(
                name: "Phone",
                table: "usuarios",
                newName: "telefone");

            migrationBuilder.RenameColumn(
                name: "PasswordHash",
                table: "usuarios",
                newName: "senha_hash");

            migrationBuilder.RenameColumn(
                name: "Name",
                table: "usuarios",
                newName: "nome_completo");

            migrationBuilder.RenameColumn(
                name: "LastLoginAt",
                table: "usuarios",
                newName: "ultimo_login");

            migrationBuilder.RenameColumn(
                name: "FailedLoginAttempts",
                table: "usuarios",
                newName: "tentativas_falhas");

            migrationBuilder.RenameColumn(
                name: "DateOfBirth",
                table: "usuarios",
                newName: "data_nascimento");

            migrationBuilder.RenameColumn(
                name: "CreatedAt",
                table: "usuarios",
                newName: "criado_em");

            migrationBuilder.RenameColumn(
                name: "BlockedAt",
                table: "usuarios",
                newName: "bloqueado_ate");

            migrationBuilder.RenameColumn(
                name: "Id",
                table: "pacientes",
                newName: "id");

            migrationBuilder.RenameColumn(
                name: "UpdatedAt",
                table: "pacientes",
                newName: "atualizado_em");

            migrationBuilder.RenameColumn(
                name: "Phone",
                table: "pacientes",
                newName: "telefone");

            migrationBuilder.RenameColumn(
                name: "Gender",
                table: "pacientes",
                newName: "sexo");

            migrationBuilder.RenameColumn(
                name: "CreatedAt",
                table: "pacientes",
                newName: "criado_em");

            migrationBuilder.RenameColumn(
                name: "Address",
                table: "pacientes",
                newName: "endereco_json");

            migrationBuilder.RenameColumn(
                name: "DateOfBirth",
                table: "pacientes",
                newName: "data_nascimento");

            migrationBuilder.RenameColumn(
                name: "Id",
                table: "odontogramas",
                newName: "id");

            migrationBuilder.RenameColumn(
                name: "UpdatedBy",
                table: "odontogramas",
                newName: "atualizado_por");

            migrationBuilder.RenameColumn(
                name: "UpdatedAt",
                table: "odontogramas",
                newName: "atualizado_em");

            migrationBuilder.RenameColumn(
                name: "Teeth",
                table: "odontogramas",
                newName: "dados_dentes_json");

            migrationBuilder.RenameColumn(
                name: "PatientId",
                table: "odontogramas",
                newName: "paciente_id");

            migrationBuilder.RenameColumn(
                name: "CreatedAt",
                table: "odontogramas",
                newName: "criado_em");

            migrationBuilder.RenameIndex(
                name: "IX_odontogramas_PatientId",
                table: "odontogramas",
                newName: "IX_odontogramas_paciente_id");

            migrationBuilder.RenameColumn(
                name: "CreatedAt",
                table: "MedicalRecords",
                newName: "DateOpened");

            migrationBuilder.RenameColumn(
                name: "Id",
                table: "lista_espera",
                newName: "id");

            migrationBuilder.RenameColumn(
                name: "Specialty",
                table: "lista_espera",
                newName: "especialidade");

            migrationBuilder.RenameColumn(
                name: "Priority",
                table: "lista_espera",
                newName: "prioridade");

            migrationBuilder.RenameColumn(
                name: "PatientId",
                table: "lista_espera",
                newName: "paciente_id");

            migrationBuilder.RenameColumn(
                name: "Observation",
                table: "lista_espera",
                newName: "observacao");

            migrationBuilder.RenameColumn(
                name: "IsResolved",
                table: "lista_espera",
                newName: "resolvido");

            migrationBuilder.RenameColumn(
                name: "CreatedAt",
                table: "lista_espera",
                newName: "criado_em");

            migrationBuilder.RenameColumn(
                name: "ClinicId",
                table: "lista_espera",
                newName: "clinica_id");

            migrationBuilder.RenameIndex(
                name: "IX_lista_espera_PatientId",
                table: "lista_espera",
                newName: "IX_lista_espera_paciente_id");

            migrationBuilder.RenameIndex(
                name: "IX_lista_espera_ClinicId",
                table: "lista_espera",
                newName: "IX_lista_espera_clinica_id");

            migrationBuilder.RenameColumn(
                name: "Id",
                table: "clinicas",
                newName: "id");

            migrationBuilder.RenameColumn(
                name: "UpdatedAt",
                table: "clinicas",
                newName: "atualizado_em");

            migrationBuilder.RenameColumn(
                name: "Specialty",
                table: "clinicas",
                newName: "especialidade");

            migrationBuilder.RenameColumn(
                name: "Name",
                table: "clinicas",
                newName: "nome");

            migrationBuilder.RenameColumn(
                name: "IsActive",
                table: "clinicas",
                newName: "ativo");

            migrationBuilder.RenameColumn(
                name: "Description",
                table: "clinicas",
                newName: "descricao");

            migrationBuilder.RenameColumn(
                name: "CreatedAt",
                table: "clinicas",
                newName: "criado_em");

            migrationBuilder.RenameColumn(
                name: "Id",
                table: "anamneses",
                newName: "id");

            migrationBuilder.RenameColumn(
                name: "UpdatedAt",
                table: "anamneses",
                newName: "atualizado_em");

            migrationBuilder.RenameColumn(
                name: "RespostasJson",
                table: "anamneses",
                newName: "respostas_json");

            migrationBuilder.RenameColumn(
                name: "PatientId",
                table: "anamneses",
                newName: "paciente_id");

            migrationBuilder.RenameColumn(
                name: "CriadoPorId",
                table: "anamneses",
                newName: "criado_por_id");

            migrationBuilder.RenameColumn(
                name: "CreatedAt",
                table: "anamneses",
                newName: "criado_em");

            migrationBuilder.RenameIndex(
                name: "IX_anamneses_PatientId",
                table: "anamneses",
                newName: "IX_anamneses_paciente_id");

            migrationBuilder.RenameIndex(
                name: "IX_anamneses_CriadoPorId",
                table: "anamneses",
                newName: "IX_anamneses_criado_por_id");

            migrationBuilder.RenameColumn(
                name: "Acao",
                table: "logs_auditoria",
                newName: "acao");

            migrationBuilder.RenameColumn(
                name: "Id",
                table: "logs_auditoria",
                newName: "id");

            migrationBuilder.RenameColumn(
                name: "DataHora",
                table: "logs_auditoria",
                newName: "data_hora");

            migrationBuilder.RenameColumn(
                name: "Id",
                table: "evolucoes",
                newName: "id");

            migrationBuilder.RenameColumn(
                name: "StudentId",
                table: "evolucoes",
                newName: "aluno_id");

            migrationBuilder.RenameColumn(
                name: "ProfessorId",
                table: "evolucoes",
                newName: "professor_id");

            migrationBuilder.RenameColumn(
                name: "PatientId",
                table: "evolucoes",
                newName: "prontuario_id");

            migrationBuilder.RenameColumn(
                name: "IsSignedByProfessor",
                table: "evolucoes",
                newName: "assinatura_professor_digital");

            migrationBuilder.RenameColumn(
                name: "Description",
                table: "evolucoes",
                newName: "descricao");

            migrationBuilder.RenameColumn(
                name: "CreatedAt",
                table: "evolucoes",
                newName: "data_atendimento");

            migrationBuilder.RenameColumn(
                name: "ClinicId",
                table: "evolucoes",
                newName: "clinica_id");

            migrationBuilder.RenameIndex(
                name: "IX_evolucoes_clinicas_StudentId",
                table: "evolucoes",
                newName: "IX_evolucoes_aluno_id");

            migrationBuilder.RenameIndex(
                name: "IX_evolucoes_clinicas_ProfessorId",
                table: "evolucoes",
                newName: "IX_evolucoes_professor_id");

            migrationBuilder.RenameIndex(
                name: "IX_evolucoes_clinicas_PatientId",
                table: "evolucoes",
                newName: "IX_evolucoes_prontuario_id");

            migrationBuilder.RenameIndex(
                name: "IX_evolucoes_clinicas_ClinicId",
                table: "evolucoes",
                newName: "IX_evolucoes_clinica_id");

            migrationBuilder.AddColumn<bool>(
                name: "ativo",
                table: "usuarios",
                type: "boolean",
                nullable: false,
                defaultValue: true);

            migrationBuilder.AlterColumn<Guid>(
                name: "PatientId",
                table: "receitas",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<string>(
                name: "email",
                table: "pacientes",
                type: "character varying(255)",
                maxLength: 255,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(100)",
                oldMaxLength: 100);

            migrationBuilder.AlterColumn<Guid>(
                name: "id",
                table: "pacientes",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer")
                .OldAnnotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn);

            migrationBuilder.AlterColumn<string>(
                name: "sexo",
                table: "pacientes",
                type: "character varying(1)",
                maxLength: 1,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "character varying(50)",
                oldMaxLength: 50,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "endereco_json",
                table: "pacientes",
                type: "jsonb",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "character varying(200)",
                oldMaxLength: 200,
                oldNullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "consentimento_lgpd",
                table: "pacientes",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "nome_completo",
                table: "pacientes",
                type: "character varying(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<Guid>(
                name: "paciente_id",
                table: "odontogramas",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<Guid>(
                name: "PatientId",
                table: "MedicalRecords",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<Guid>(
                name: "Id",
                table: "MedicalRecords",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer")
                .OldAnnotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn);

            migrationBuilder.AddColumn<string>(
                name: "Status",
                table: "MedicalRecords",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<int>(
                name: "especialidade",
                table: "lista_espera",
                type: "integer",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<string>(
                name: "prioridade",
                table: "lista_espera",
                type: "character varying(50)",
                maxLength: 50,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(20)",
                oldMaxLength: 20);

            migrationBuilder.AlterColumn<Guid>(
                name: "paciente_id",
                table: "lista_espera",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<bool>(
                name: "resolvido",
                table: "lista_espera",
                type: "boolean",
                nullable: false,
                defaultValue: false,
                oldClrType: typeof(bool),
                oldType: "boolean");

            migrationBuilder.AlterColumn<string>(
                name: "descricao",
                table: "clinicas",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(1000)",
                oldMaxLength: 1000);

            migrationBuilder.AlterColumn<Guid>(
                name: "UploadedByUserId",
                table: "Attachments",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.AlterColumn<Guid>(
                name: "PatientId",
                table: "Attachments",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<Guid>(
                name: "MedicalRecordId",
                table: "Attachments",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.AlterColumn<Guid>(
                name: "Id",
                table: "Attachments",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer")
                .OldAnnotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn);

            migrationBuilder.AlterColumn<Guid>(
                name: "PatientId",
                table: "atestados",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<Guid>(
                name: "PacienteId",
                table: "anexos",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<Guid>(
                name: "CriadoPorId",
                table: "anexos",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AddColumn<string>(
                name: "MetaData",
                table: "anexos",
                type: "text",
                nullable: true);

            migrationBuilder.AlterColumn<Guid>(
                name: "paciente_id",
                table: "anamneses",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<Guid>(
                name: "PatientId",
                table: "agendamentos",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<string>(
                name: "acao",
                table: "logs_auditoria",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<Guid>(
                name: "id",
                table: "logs_auditoria",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer")
                .OldAnnotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn);

            migrationBuilder.AlterColumn<DateTime>(
                name: "data_hora",
                table: "logs_auditoria",
                type: "timestamp with time zone",
                nullable: false,
                defaultValueSql: "CURRENT_TIMESTAMP",
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone");

            migrationBuilder.AddColumn<string>(
                name: "detalhes",
                table: "logs_auditoria",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ip_address",
                table: "logs_auditoria",
                type: "character varying(45)",
                maxLength: 45,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "recurso",
                table: "logs_auditoria",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "user_agent",
                table: "logs_auditoria",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "usuario_id",
                table: "logs_auditoria",
                type: "uuid",
                nullable: true);

            migrationBuilder.AlterColumn<Guid>(
                name: "prontuario_id",
                table: "evolucoes",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<string>(
                name: "assinatura_professor_digital",
                table: "evolucoes",
                type: "text",
                nullable: false,
                oldClrType: typeof(bool),
                oldType: "boolean",
                oldDefaultValue: false);

            migrationBuilder.AddPrimaryKey(
                name: "PK_logs_auditoria",
                table: "logs_auditoria",
                column: "id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_evolucoes",
                table: "evolucoes",
                column: "id");

            migrationBuilder.CreateTable(
                name: "patient_change_logs",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    patient_id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_name = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    timestamp = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    changes_json = table.Column<string>(type: "jsonb", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_patient_change_logs", x => x.id);
                    table.ForeignKey(
                        name: "FK_patient_change_logs_pacientes_patient_id",
                        column: x => x.patient_id,
                        principalTable: "pacientes",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_pacientes_nome_completo",
                table: "pacientes",
                column: "nome_completo");

            migrationBuilder.CreateIndex(
                name: "IX_logs_auditoria_usuario_id",
                table: "logs_auditoria",
                column: "usuario_id");

            migrationBuilder.CreateIndex(
                name: "IX_patient_change_logs_patient_id",
                table: "patient_change_logs",
                column: "patient_id");

            migrationBuilder.CreateIndex(
                name: "IX_patient_change_logs_patient_id_timestamp",
                table: "patient_change_logs",
                columns: new[] { "patient_id", "timestamp" });

            migrationBuilder.AddForeignKey(
                name: "FK_anamneses_pacientes_paciente_id",
                table: "anamneses",
                column: "paciente_id",
                principalTable: "pacientes",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_anamneses_usuarios_criado_por_id",
                table: "anamneses",
                column: "criado_por_id",
                principalTable: "usuarios",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_evolucoes_clinicas_clinica_id",
                table: "evolucoes",
                column: "clinica_id",
                principalTable: "clinicas",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_evolucoes_pacientes_prontuario_id",
                table: "evolucoes",
                column: "prontuario_id",
                principalTable: "pacientes",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_evolucoes_usuarios_aluno_id",
                table: "evolucoes",
                column: "aluno_id",
                principalTable: "usuarios",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_evolucoes_usuarios_professor_id",
                table: "evolucoes",
                column: "professor_id",
                principalTable: "usuarios",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_lista_espera_clinicas_clinica_id",
                table: "lista_espera",
                column: "clinica_id",
                principalTable: "clinicas",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_lista_espera_pacientes_paciente_id",
                table: "lista_espera",
                column: "paciente_id",
                principalTable: "pacientes",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_logs_auditoria_usuarios_usuario_id",
                table: "logs_auditoria",
                column: "usuario_id",
                principalTable: "usuarios",
                principalColumn: "id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_odontogramas_pacientes_paciente_id",
                table: "odontogramas",
                column: "paciente_id",
                principalTable: "pacientes",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_anamneses_pacientes_paciente_id",
                table: "anamneses");

            migrationBuilder.DropForeignKey(
                name: "FK_anamneses_usuarios_criado_por_id",
                table: "anamneses");

            migrationBuilder.DropForeignKey(
                name: "FK_evolucoes_clinicas_clinica_id",
                table: "evolucoes");

            migrationBuilder.DropForeignKey(
                name: "FK_evolucoes_pacientes_prontuario_id",
                table: "evolucoes");

            migrationBuilder.DropForeignKey(
                name: "FK_evolucoes_usuarios_aluno_id",
                table: "evolucoes");

            migrationBuilder.DropForeignKey(
                name: "FK_evolucoes_usuarios_professor_id",
                table: "evolucoes");

            migrationBuilder.DropForeignKey(
                name: "FK_lista_espera_clinicas_clinica_id",
                table: "lista_espera");

            migrationBuilder.DropForeignKey(
                name: "FK_lista_espera_pacientes_paciente_id",
                table: "lista_espera");

            migrationBuilder.DropForeignKey(
                name: "FK_logs_auditoria_usuarios_usuario_id",
                table: "logs_auditoria");

            migrationBuilder.DropForeignKey(
                name: "FK_odontogramas_pacientes_paciente_id",
                table: "odontogramas");

            migrationBuilder.DropTable(
                name: "patient_change_logs");

            migrationBuilder.DropIndex(
                name: "IX_pacientes_nome_completo",
                table: "pacientes");

            migrationBuilder.DropPrimaryKey(
                name: "PK_logs_auditoria",
                table: "logs_auditoria");

            migrationBuilder.DropIndex(
                name: "IX_logs_auditoria_usuario_id",
                table: "logs_auditoria");

            migrationBuilder.DropPrimaryKey(
                name: "PK_evolucoes",
                table: "evolucoes");

            migrationBuilder.DropColumn(
                name: "ativo",
                table: "usuarios");

            migrationBuilder.DropColumn(
                name: "consentimento_lgpd",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "nome_completo",
                table: "pacientes");

            migrationBuilder.DropColumn(
                name: "Status",
                table: "MedicalRecords");

            migrationBuilder.DropColumn(
                name: "MetaData",
                table: "anexos");

            migrationBuilder.DropColumn(
                name: "detalhes",
                table: "logs_auditoria");

            migrationBuilder.DropColumn(
                name: "ip_address",
                table: "logs_auditoria");

            migrationBuilder.DropColumn(
                name: "recurso",
                table: "logs_auditoria");

            migrationBuilder.DropColumn(
                name: "user_agent",
                table: "logs_auditoria");

            migrationBuilder.DropColumn(
                name: "usuario_id",
                table: "logs_auditoria");

            migrationBuilder.RenameTable(
                name: "logs_auditoria",
                newName: "LogsAuditoria");

            migrationBuilder.RenameTable(
                name: "evolucoes",
                newName: "evolucoes_clinicas");

            migrationBuilder.RenameColumn(
                name: "id",
                table: "usuarios",
                newName: "Id");

            migrationBuilder.RenameColumn(
                name: "ultimo_login",
                table: "usuarios",
                newName: "LastLoginAt");

            migrationBuilder.RenameColumn(
                name: "tentativas_falhas",
                table: "usuarios",
                newName: "FailedLoginAttempts");

            migrationBuilder.RenameColumn(
                name: "telefone",
                table: "usuarios",
                newName: "Phone");

            migrationBuilder.RenameColumn(
                name: "senha_hash",
                table: "usuarios",
                newName: "PasswordHash");

            migrationBuilder.RenameColumn(
                name: "perfis_json",
                table: "usuarios",
                newName: "Roles");

            migrationBuilder.RenameColumn(
                name: "nome_completo",
                table: "usuarios",
                newName: "Name");

            migrationBuilder.RenameColumn(
                name: "data_nascimento",
                table: "usuarios",
                newName: "DateOfBirth");

            migrationBuilder.RenameColumn(
                name: "criado_em",
                table: "usuarios",
                newName: "CreatedAt");

            migrationBuilder.RenameColumn(
                name: "bloqueado_ate",
                table: "usuarios",
                newName: "BlockedAt");

            migrationBuilder.RenameColumn(
                name: "atualizado_em",
                table: "usuarios",
                newName: "UpdatedAt");

            migrationBuilder.RenameColumn(
                name: "id",
                table: "pacientes",
                newName: "Id");

            migrationBuilder.RenameColumn(
                name: "telefone",
                table: "pacientes",
                newName: "Phone");

            migrationBuilder.RenameColumn(
                name: "sexo",
                table: "pacientes",
                newName: "Gender");

            migrationBuilder.RenameColumn(
                name: "endereco_json",
                table: "pacientes",
                newName: "Address");

            migrationBuilder.RenameColumn(
                name: "criado_em",
                table: "pacientes",
                newName: "CreatedAt");

            migrationBuilder.RenameColumn(
                name: "atualizado_em",
                table: "pacientes",
                newName: "UpdatedAt");

            migrationBuilder.RenameColumn(
                name: "data_nascimento",
                table: "pacientes",
                newName: "DateOfBirth");

            migrationBuilder.RenameColumn(
                name: "id",
                table: "odontogramas",
                newName: "Id");

            migrationBuilder.RenameColumn(
                name: "paciente_id",
                table: "odontogramas",
                newName: "PatientId");

            migrationBuilder.RenameColumn(
                name: "dados_dentes_json",
                table: "odontogramas",
                newName: "Teeth");

            migrationBuilder.RenameColumn(
                name: "criado_em",
                table: "odontogramas",
                newName: "CreatedAt");

            migrationBuilder.RenameColumn(
                name: "atualizado_por",
                table: "odontogramas",
                newName: "UpdatedBy");

            migrationBuilder.RenameColumn(
                name: "atualizado_em",
                table: "odontogramas",
                newName: "UpdatedAt");

            migrationBuilder.RenameIndex(
                name: "IX_odontogramas_paciente_id",
                table: "odontogramas",
                newName: "IX_odontogramas_PatientId");

            migrationBuilder.RenameColumn(
                name: "DateOpened",
                table: "MedicalRecords",
                newName: "CreatedAt");

            migrationBuilder.RenameColumn(
                name: "id",
                table: "lista_espera",
                newName: "Id");

            migrationBuilder.RenameColumn(
                name: "resolvido",
                table: "lista_espera",
                newName: "IsResolved");

            migrationBuilder.RenameColumn(
                name: "prioridade",
                table: "lista_espera",
                newName: "Priority");

            migrationBuilder.RenameColumn(
                name: "paciente_id",
                table: "lista_espera",
                newName: "PatientId");

            migrationBuilder.RenameColumn(
                name: "observacao",
                table: "lista_espera",
                newName: "Observation");

            migrationBuilder.RenameColumn(
                name: "especialidade",
                table: "lista_espera",
                newName: "Specialty");

            migrationBuilder.RenameColumn(
                name: "criado_em",
                table: "lista_espera",
                newName: "CreatedAt");

            migrationBuilder.RenameColumn(
                name: "clinica_id",
                table: "lista_espera",
                newName: "ClinicId");

            migrationBuilder.RenameIndex(
                name: "IX_lista_espera_paciente_id",
                table: "lista_espera",
                newName: "IX_lista_espera_PatientId");

            migrationBuilder.RenameIndex(
                name: "IX_lista_espera_clinica_id",
                table: "lista_espera",
                newName: "IX_lista_espera_ClinicId");

            migrationBuilder.RenameColumn(
                name: "id",
                table: "clinicas",
                newName: "Id");

            migrationBuilder.RenameColumn(
                name: "nome",
                table: "clinicas",
                newName: "Name");

            migrationBuilder.RenameColumn(
                name: "especialidade",
                table: "clinicas",
                newName: "Specialty");

            migrationBuilder.RenameColumn(
                name: "descricao",
                table: "clinicas",
                newName: "Description");

            migrationBuilder.RenameColumn(
                name: "criado_em",
                table: "clinicas",
                newName: "CreatedAt");

            migrationBuilder.RenameColumn(
                name: "atualizado_em",
                table: "clinicas",
                newName: "UpdatedAt");

            migrationBuilder.RenameColumn(
                name: "ativo",
                table: "clinicas",
                newName: "IsActive");

            migrationBuilder.RenameColumn(
                name: "id",
                table: "anamneses",
                newName: "Id");

            migrationBuilder.RenameColumn(
                name: "respostas_json",
                table: "anamneses",
                newName: "RespostasJson");

            migrationBuilder.RenameColumn(
                name: "paciente_id",
                table: "anamneses",
                newName: "PatientId");

            migrationBuilder.RenameColumn(
                name: "criado_por_id",
                table: "anamneses",
                newName: "CriadoPorId");

            migrationBuilder.RenameColumn(
                name: "criado_em",
                table: "anamneses",
                newName: "CreatedAt");

            migrationBuilder.RenameColumn(
                name: "atualizado_em",
                table: "anamneses",
                newName: "UpdatedAt");

            migrationBuilder.RenameIndex(
                name: "IX_anamneses_paciente_id",
                table: "anamneses",
                newName: "IX_anamneses_PatientId");

            migrationBuilder.RenameIndex(
                name: "IX_anamneses_criado_por_id",
                table: "anamneses",
                newName: "IX_anamneses_CriadoPorId");

            migrationBuilder.RenameColumn(
                name: "acao",
                table: "LogsAuditoria",
                newName: "Acao");

            migrationBuilder.RenameColumn(
                name: "id",
                table: "LogsAuditoria",
                newName: "Id");

            migrationBuilder.RenameColumn(
                name: "data_hora",
                table: "LogsAuditoria",
                newName: "DataHora");

            migrationBuilder.RenameColumn(
                name: "id",
                table: "evolucoes_clinicas",
                newName: "Id");

            migrationBuilder.RenameColumn(
                name: "prontuario_id",
                table: "evolucoes_clinicas",
                newName: "PatientId");

            migrationBuilder.RenameColumn(
                name: "professor_id",
                table: "evolucoes_clinicas",
                newName: "ProfessorId");

            migrationBuilder.RenameColumn(
                name: "descricao",
                table: "evolucoes_clinicas",
                newName: "Description");

            migrationBuilder.RenameColumn(
                name: "data_atendimento",
                table: "evolucoes_clinicas",
                newName: "CreatedAt");

            migrationBuilder.RenameColumn(
                name: "clinica_id",
                table: "evolucoes_clinicas",
                newName: "ClinicId");

            migrationBuilder.RenameColumn(
                name: "assinatura_professor_digital",
                table: "evolucoes_clinicas",
                newName: "IsSignedByProfessor");

            migrationBuilder.RenameColumn(
                name: "aluno_id",
                table: "evolucoes_clinicas",
                newName: "StudentId");

            migrationBuilder.RenameIndex(
                name: "IX_evolucoes_prontuario_id",
                table: "evolucoes_clinicas",
                newName: "IX_evolucoes_clinicas_PatientId");

            migrationBuilder.RenameIndex(
                name: "IX_evolucoes_professor_id",
                table: "evolucoes_clinicas",
                newName: "IX_evolucoes_clinicas_ProfessorId");

            migrationBuilder.RenameIndex(
                name: "IX_evolucoes_clinica_id",
                table: "evolucoes_clinicas",
                newName: "IX_evolucoes_clinicas_ClinicId");

            migrationBuilder.RenameIndex(
                name: "IX_evolucoes_aluno_id",
                table: "evolucoes_clinicas",
                newName: "IX_evolucoes_clinicas_StudentId");

            migrationBuilder.AddColumn<string>(
                name: "Address_Complement",
                table: "usuarios",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Role",
                table: "usuarios",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Status",
                table: "usuarios",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "endereco_bairro",
                table: "usuarios",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "endereco_cep",
                table: "usuarios",
                type: "character varying(10)",
                maxLength: 10,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "endereco_cidade",
                table: "usuarios",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "endereco_estado",
                table: "usuarios",
                type: "character varying(2)",
                maxLength: 2,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "endereco_numero",
                table: "usuarios",
                type: "character varying(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "endereco_rua",
                table: "usuarios",
                type: "character varying(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "MedicalRecordId",
                table: "TreatmentItems",
                type: "integer",
                nullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "PatientId",
                table: "receitas",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AlterColumn<string>(
                name: "email",
                table: "pacientes",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(255)",
                oldMaxLength: 255);

            migrationBuilder.AlterColumn<int>(
                name: "Id",
                table: "pacientes",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid")
                .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn);

            migrationBuilder.AlterColumn<string>(
                name: "Gender",
                table: "pacientes",
                type: "character varying(50)",
                maxLength: 50,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "character varying(1)",
                oldMaxLength: 1,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Address",
                table: "pacientes",
                type: "character varying(200)",
                maxLength: 200,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "jsonb",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Allergies",
                table: "pacientes",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "AlternatePhone",
                table: "pacientes",
                type: "character varying(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "City",
                table: "pacientes",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "pacientes",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "MedicalHistory",
                table: "pacientes",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Medications",
                table: "pacientes",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Name",
                table: "pacientes",
                type: "character varying(150)",
                maxLength: 150,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Neighborhood",
                table: "pacientes",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RG",
                table: "pacientes",
                type: "character varying(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ResponsibleName",
                table: "pacientes",
                type: "character varying(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ResponsiblePhone",
                table: "pacientes",
                type: "character varying(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "State",
                table: "pacientes",
                type: "character varying(2)",
                maxLength: 2,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ZipCode",
                table: "pacientes",
                type: "character varying(9)",
                maxLength: 9,
                nullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "PatientId",
                table: "odontogramas",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AlterColumn<int>(
                name: "PatientId",
                table: "MedicalRecords",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AlterColumn<int>(
                name: "Id",
                table: "MedicalRecords",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid")
                .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn);

            migrationBuilder.AddColumn<string>(
                name: "Anamnesis",
                table: "MedicalRecords",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "ClinicalExam",
                table: "MedicalRecords",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Diagnosis",
                table: "MedicalRecords",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TreatmentPlan",
                table: "MedicalRecords",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "MedicalRecords",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AlterColumn<bool>(
                name: "IsResolved",
                table: "lista_espera",
                type: "boolean",
                nullable: false,
                oldClrType: typeof(bool),
                oldType: "boolean",
                oldDefaultValue: false);

            migrationBuilder.AlterColumn<string>(
                name: "Priority",
                table: "lista_espera",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(50)",
                oldMaxLength: 50);

            migrationBuilder.AlterColumn<int>(
                name: "PatientId",
                table: "lista_espera",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AlterColumn<int>(
                name: "Specialty",
                table: "lista_espera",
                type: "integer",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Description",
                table: "clinicas",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<string>(
                name: "Address_Complement",
                table: "clinicas",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ClosingTime",
                table: "clinicas",
                type: "character varying(5)",
                maxLength: 5,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<Guid>(
                name: "CoordinatorUserId",
                table: "clinicas",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<int>(
                name: "MaxCapacity",
                table: "clinicas",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "OpeningTime",
                table: "clinicas",
                type: "character varying(5)",
                maxLength: 5,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "endereco_bairro",
                table: "clinicas",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "endereco_cep",
                table: "clinicas",
                type: "character varying(10)",
                maxLength: 10,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "endereco_cidade",
                table: "clinicas",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "endereco_estado",
                table: "clinicas",
                type: "character varying(2)",
                maxLength: 2,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "endereco_numero",
                table: "clinicas",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "endereco_rua",
                table: "clinicas",
                type: "character varying(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<int>(
                name: "UploadedByUserId",
                table: "Attachments",
                type: "integer",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "PatientId",
                table: "Attachments",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AlterColumn<int>(
                name: "MedicalRecordId",
                table: "Attachments",
                type: "integer",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "Id",
                table: "Attachments",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid")
                .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn);

            migrationBuilder.AddColumn<Guid>(
                name: "UserId",
                table: "Attachments",
                type: "uuid",
                nullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "PatientId",
                table: "atestados",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AlterColumn<int>(
                name: "PacienteId",
                table: "anexos",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AlterColumn<Guid>(
                name: "CriadoPorId",
                table: "anexos",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "PatientId",
                table: "anamneses",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AlterColumn<int>(
                name: "PatientId",
                table: "agendamentos",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AddColumn<Guid>(
                name: "UserId",
                table: "agendamentos",
                type: "uuid",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Acao",
                table: "LogsAuditoria",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(100)",
                oldMaxLength: 100);

            migrationBuilder.AlterColumn<int>(
                name: "Id",
                table: "LogsAuditoria",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid")
                .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn);

            migrationBuilder.AlterColumn<DateTime>(
                name: "DataHora",
                table: "LogsAuditoria",
                type: "timestamp with time zone",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone",
                oldDefaultValueSql: "CURRENT_TIMESTAMP");

            migrationBuilder.AddColumn<string>(
                name: "DadosAntigos",
                table: "LogsAuditoria",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "DadosNovos",
                table: "LogsAuditoria",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "IpOrigem",
                table: "LogsAuditoria",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Tabela",
                table: "LogsAuditoria",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Usuario",
                table: "LogsAuditoria",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<int>(
                name: "PatientId",
                table: "evolucoes_clinicas",
                type: "integer",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AlterColumn<bool>(
                name: "IsSignedByProfessor",
                table: "evolucoes_clinicas",
                type: "boolean",
                nullable: false,
                defaultValue: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<int>(
                name: "MedicalRecordId",
                table: "evolucoes_clinicas",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "SignedAt",
                table: "evolucoes_clinicas",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "evolucoes_clinicas",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "UserId",
                table: "evolucoes_clinicas",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_LogsAuditoria",
                table: "LogsAuditoria",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_evolucoes_clinicas",
                table: "evolucoes_clinicas",
                column: "Id");

            migrationBuilder.CreateIndex(
                name: "IX_TreatmentItems_MedicalRecordId",
                table: "TreatmentItems",
                column: "MedicalRecordId");

            migrationBuilder.CreateIndex(
                name: "IX_pacientes_Name",
                table: "pacientes",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_odontogramas_UpdatedAt",
                table: "odontogramas",
                column: "UpdatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_lista_espera_IsResolved",
                table: "lista_espera",
                column: "IsResolved");

            migrationBuilder.CreateIndex(
                name: "IX_Attachments_MedicalRecordId",
                table: "Attachments",
                column: "MedicalRecordId");

            migrationBuilder.CreateIndex(
                name: "IX_Attachments_UserId",
                table: "Attachments",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_agendamentos_UserId",
                table: "agendamentos",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_evolucoes_clinicas_CreatedAt",
                table: "evolucoes_clinicas",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_evolucoes_clinicas_MedicalRecordId",
                table: "evolucoes_clinicas",
                column: "MedicalRecordId");

            migrationBuilder.CreateIndex(
                name: "IX_evolucoes_clinicas_UserId",
                table: "evolucoes_clinicas",
                column: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_agendamentos_usuarios_UserId",
                table: "agendamentos",
                column: "UserId",
                principalTable: "usuarios",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_anamneses_pacientes_PatientId",
                table: "anamneses",
                column: "PatientId",
                principalTable: "pacientes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_anamneses_usuarios_CriadoPorId",
                table: "anamneses",
                column: "CriadoPorId",
                principalTable: "usuarios",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Attachments_MedicalRecords_MedicalRecordId",
                table: "Attachments",
                column: "MedicalRecordId",
                principalTable: "MedicalRecords",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Attachments_usuarios_UserId",
                table: "Attachments",
                column: "UserId",
                principalTable: "usuarios",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_evolucoes_clinicas_MedicalRecords_MedicalRecordId",
                table: "evolucoes_clinicas",
                column: "MedicalRecordId",
                principalTable: "MedicalRecords",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_evolucoes_clinicas_clinicas_ClinicId",
                table: "evolucoes_clinicas",
                column: "ClinicId",
                principalTable: "clinicas",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_evolucoes_clinicas_pacientes_PatientId",
                table: "evolucoes_clinicas",
                column: "PatientId",
                principalTable: "pacientes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_evolucoes_clinicas_usuarios_ProfessorId",
                table: "evolucoes_clinicas",
                column: "ProfessorId",
                principalTable: "usuarios",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_evolucoes_clinicas_usuarios_StudentId",
                table: "evolucoes_clinicas",
                column: "StudentId",
                principalTable: "usuarios",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_evolucoes_clinicas_usuarios_UserId",
                table: "evolucoes_clinicas",
                column: "UserId",
                principalTable: "usuarios",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_lista_espera_clinicas_ClinicId",
                table: "lista_espera",
                column: "ClinicId",
                principalTable: "clinicas",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_lista_espera_pacientes_PatientId",
                table: "lista_espera",
                column: "PatientId",
                principalTable: "pacientes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_odontogramas_pacientes_PatientId",
                table: "odontogramas",
                column: "PatientId",
                principalTable: "pacientes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_TreatmentItems_MedicalRecords_MedicalRecordId",
                table: "TreatmentItems",
                column: "MedicalRecordId",
                principalTable: "MedicalRecords",
                principalColumn: "Id");
        }
    }
}
