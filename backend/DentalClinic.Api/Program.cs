using System.Text;
using DentalClinic.Core.Application.Interfaces;
using DentalClinic.Core.Application.Services;
using DentalClinic.Core.Domain.Repositories;
using DentalClinic.Infrastructure.Persistence;
using DentalClinic.Infrastructure.Persistence.Repositories;
using DentalClinic.Infrastructure.Security;
using DentalClinic.Infrastructure.Storage;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using DentalClinic.Api.Middlewares;
using DentalClinic.Api.Filters;
using DentalClinic.Api.Hubs;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.ValueObjects;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// 1. Configuração do Banco de Dados com suporte a JSONB
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
var dataSourceBuilder = new NpgsqlDataSourceBuilder(connectionString);
dataSourceBuilder.EnableDynamicJson();
var dataSource = dataSourceBuilder.Build();

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(dataSource));

// 2. Injeção de Dependências
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IPatientRepository, PatientRepository>();
builder.Services.AddScoped<IAppointmentRepository, AppointmentRepository>();
builder.Services.AddScoped<IClinicRepository, ClinicRepository>();
builder.Services.AddScoped<IProntuarioRepository, ProntuarioRepository>();
builder.Services.AddScoped<ITreatmentPlanRepository, TreatmentPlanRepository>();
builder.Services.AddScoped<IUserSessionRepository, UserSessionRepository>();
builder.Services.AddScoped<IReportRepository, ReportRepository>();
builder.Services.AddScoped<IWaitListRepository, WaitListRepository>();
builder.Services.AddScoped<INotificationRepository, NotificationRepository>();
builder.Services.AddScoped<IAnexoRepository, AnexoRepository>();
builder.Services.AddScoped<IPatientChangeLogRepository, PatientChangeLogRepository>();

builder.Services.AddScoped<IPasswordHasher, PasswordHasher>();
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IAppointmentService, AppointmentService>();
builder.Services.AddScoped<IStorageService, LocalStorageService>();

builder.Services.AddSignalR();

builder.Services.AddControllers(options =>
{
    options.Filters.Add<AuditFilter>();
}).AddJsonOptions(options =>
{
    options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
    options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
});

// 5. Configuração JWT
var jwtSettings = builder.Configuration.GetSection("Jwt");
var key = Encoding.ASCII.GetBytes(jwtSettings["Key"]!);

builder.Services.AddAuthentication(x =>
{
    x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(x =>
{
    x.RequireHttpsMetadata = false;
    x.SaveToken = true;
    x.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidateAudience = true,
        ValidAudience = jwtSettings["Audience"],
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero
    };
});

// 6. CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutter", policy =>
    {
        policy.SetIsOriginAllowed(_ => true)
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials();
    });
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "OdontoClinica API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header. Example: \"Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

app.UseMiddleware<ExceptionMiddleware>();

// Swagger configurado para o caminho padrão /swagger
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "OdontoClinica API V1");
});

var uploadsDir = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
Directory.CreateDirectory(uploadsDir);
app.UseStaticFiles();
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(uploadsDir),
    RequestPath = "/uploads",
    ServeUnknownFileTypes = true,
    DefaultContentType = "application/octet-stream"
});
app.UseCors("AllowFlutter");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<ClinicHub>("/hubs/clinic");

// 9. Lógica de Seed Robusta (Garante o Admin e loga no console)
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var context = services.GetRequiredService<ApplicationDbContext>();
    var hasher = services.GetRequiredService<IPasswordHasher>();

    try {
        context.Database.ExecuteSqlRaw(@"
            CREATE TABLE IF NOT EXISTS ""__EFMigrationsHistory"" (
                ""MigrationId"" character varying(150) NOT NULL PRIMARY KEY,
                ""ProductVersion"" character varying(32) NOT NULL
            );

            ALTER TABLE IF EXISTS pacientes
                ADD COLUMN IF NOT EXISTS ultima_modificacao timestamp with time zone,
                ADD COLUMN IF NOT EXISTS nome_social character varying(255),
                ADD COLUMN IF NOT EXISTS numero_sus character varying(15),
                ADD COLUMN IF NOT EXISTS endereco_rua character varying(255),
                ADD COLUMN IF NOT EXISTS endereco_numero character varying(20),
                ADD COLUMN IF NOT EXISTS endereco_complemento text,
                ADD COLUMN IF NOT EXISTS endereco_bairro character varying(100),
                ADD COLUMN IF NOT EXISTS endereco_cidade character varying(100),
                ADD COLUMN IF NOT EXISTS endereco_estado character varying(2),
                ADD COLUMN IF NOT EXISTS endereco_cep character varying(10);
            ALTER TABLE IF EXISTS pacientes
                ALTER COLUMN ultima_modificacao SET DEFAULT now();
            UPDATE pacientes SET ultima_modificacao = COALESCE(ultima_modificacao, now())
                WHERE ultima_modificacao IS NULL;

            -- CORREÇÃO: remove restrições NOT NULL legadas de colunas que hoje
            -- são opcionais na entidade Patient (email/telefone). Sem isso, o
            -- INSERT de um paciente vindo do app sem e-mail falhava no banco,
            -- o paciente ficava só no SQLite local e o agendamento retornava
            -- paciente selecionado inexistente no servidor
            ALTER TABLE IF EXISTS pacientes
                ALTER COLUMN email DROP NOT NULL,
                ALTER COLUMN telefone DROP NOT NULL,
                ALTER COLUMN sexo DROP NOT NULL,
                ALTER COLUMN nome_social DROP NOT NULL,
                ALTER COLUMN numero_sus DROP NOT NULL,
                ALTER COLUMN endereco_rua DROP NOT NULL,
                ALTER COLUMN endereco_numero DROP NOT NULL,
                ALTER COLUMN endereco_complemento DROP NOT NULL,
                ALTER COLUMN endereco_bairro DROP NOT NULL,
                ALTER COLUMN endereco_cidade DROP NOT NULL,
                ALTER COLUMN endereco_estado DROP NOT NULL,
                ALTER COLUMN endereco_cep DROP NOT NULL;

            INSERT INTO ""__EFMigrationsHistory"" (""MigrationId"", ""ProductVersion"")
            SELECT migration_id, '9.0.0'
            FROM (VALUES
                ('20260720024143_FixForeignKeysAndTypes'),
                ('20260720025121_InitialCreate'),
                ('20260720065402_FixRelations_v2')
            ) AS applied(migration_id)
            WHERE to_regclass('public.clinicas') IS NOT NULL
              AND to_regclass('public.pacientes') IS NOT NULL
              AND to_regclass('public.agendamentos') IS NOT NULL
            ON CONFLICT (""MigrationId"") DO NOTHING;

            INSERT INTO ""__EFMigrationsHistory"" (""MigrationId"", ""ProductVersion"")
            SELECT '20261121060519_AddPatientSocialNameAndSusNumber', '9.0.0'
            WHERE to_regclass('public.pacientes') IS NOT NULL
              AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'pacientes' AND column_name = 'nome_social')
              AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'pacientes' AND column_name = 'numero_sus')
            ON CONFLICT (""MigrationId"") DO NOTHING;

            INSERT INTO ""__EFMigrationsHistory"" (""MigrationId"", ""ProductVersion"")
            SELECT '20261121082236_AddAppointmentResponsiblesAndTimes', '9.0.0'
            WHERE to_regclass('public.agendamentos') IS NOT NULL
              AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'agendamentos' AND column_name = 'StudentId')
              AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'agendamentos' AND column_name = 'ProfessorId')
              AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'agendamentos' AND column_name = 'ArrivalTime')
            ON CONFLICT (""MigrationId"") DO NOTHING;
        ");

        context.Database.Migrate();

        // Garante que todas as tabelas e colunas do Prontuário existam mesmo em bancos legados
        context.Database.ExecuteSqlRaw(@"
            CREATE TABLE IF NOT EXISTS public.prontuario_fichas (
                id uuid PRIMARY KEY,
                paciente_id uuid NOT NULL,
                tipo character varying(64) NOT NULL,
                dados_json jsonb NOT NULL DEFAULT '{}'::jsonb,
                versao integer NOT NULL DEFAULT 1,
                criado_por uuid NOT NULL,
                criado_em timestamp with time zone NOT NULL DEFAULT now(),
                atualizado_em timestamp with time zone NULL
            );
            CREATE INDEX IF NOT EXISTS ix_prontuario_fichas_paciente_tipo
                ON public.prontuario_fichas (paciente_id, tipo, versao DESC);

            CREATE TABLE IF NOT EXISTS public.odontogramas (
                id uuid PRIMARY KEY,
                paciente_id uuid NOT NULL,
                dados_dentes_json jsonb NOT NULL DEFAULT '[]'::jsonb,
                atualizado_por uuid NOT NULL,
                criado_em timestamp with time zone NOT NULL DEFAULT now(),
                atualizado_em timestamp with time zone NULL
            );

            CREATE TABLE IF NOT EXISTS public.anamneses (
                id uuid PRIMARY KEY,
                paciente_id uuid NOT NULL,
                criado_por_id uuid NOT NULL,
                respostas_json jsonb NOT NULL DEFAULT '{}'::jsonb,
                criado_em timestamp with time zone NOT NULL DEFAULT now(),
                atualizado_em timestamp with time zone NULL
            );

            CREATE TABLE IF NOT EXISTS public.receitas (
                ""Id"" uuid PRIMARY KEY,
                ""PatientId"" uuid NOT NULL,
                ""DoctorId"" uuid NOT NULL,
                ""Observations"" character varying(1000) NULL,
                ""Items"" jsonb NOT NULL DEFAULT '[]'::jsonb,
                ""ClinicId"" uuid NOT NULL,
                ""CreatedAt"" timestamp with time zone NOT NULL DEFAULT now(),
                ""UpdatedAt"" timestamp with time zone NULL
            );

            CREATE TABLE IF NOT EXISTS public.atestados (
                ""Id"" uuid PRIMARY KEY,
                ""PatientId"" uuid NOT NULL,
                ""DoctorId"" uuid NOT NULL,
                ""Content"" text NOT NULL,
                ""DaysOfRest"" integer NOT NULL DEFAULT 1,
                ""CID"" character varying(10) NOT NULL DEFAULT '',
                ""ClinicId"" uuid NOT NULL,
                ""CreatedAt"" timestamp with time zone NOT NULL DEFAULT now(),
                ""UpdatedAt"" timestamp with time zone NULL
            );

            CREATE TABLE IF NOT EXISTS public.""TreatmentPlans"" (
                ""Id"" uuid PRIMARY KEY,
                ""PatientId"" uuid NOT NULL,
                ""Description"" text NOT NULL DEFAULT '',
                ""CreatedByUserId"" uuid NOT NULL,
                ""Status"" integer NOT NULL DEFAULT 1,
                ""CreatedAt"" timestamp with time zone NOT NULL DEFAULT now(),
                ""UpdatedAt"" timestamp with time zone NULL
            );

            CREATE TABLE IF NOT EXISTS public.""TreatmentItems"" (
                ""Id"" uuid PRIMARY KEY,
                ""TreatmentPlanId"" uuid NOT NULL,
                ""ProcedureId"" uuid NOT NULL,
                ""ProcedureName"" text NOT NULL DEFAULT '',
                ""Value"" numeric NOT NULL DEFAULT 0,
                ""ToothNumber"" integer NULL,
                ""Observation"" text NULL,
                ""Status"" integer NOT NULL DEFAULT 1,
                ""CreatedAt"" timestamp with time zone NOT NULL DEFAULT now(),
                ""UpdatedAt"" timestamp with time zone NULL
            );
            ALTER TABLE IF EXISTS public.""TreatmentItems""
                ADD COLUMN IF NOT EXISTS ""Observation"" text NULL;

            ALTER TABLE IF EXISTS public.evolucoes
                ADD COLUMN IF NOT EXISTS assinado_em timestamp with time zone NULL;

            -- Se a FK legada evolucoes_prontuario_id_fkey apontar para prontuarios em vez de pacientes, remove para permitir gravação direta por paciente
            DO $$
            BEGIN
                IF EXISTS (
                    SELECT 1
                    FROM pg_constraint con
                    JOIN pg_class rel ON rel.oid = con.conrelid
                    JOIN pg_class ref ON ref.oid = con.confrelid
                    WHERE rel.relname = 'evolucoes'
                      AND ref.relname = 'prontuarios'
                      AND con.conname = 'evolucoes_prontuario_id_fkey'
                ) THEN
                    ALTER TABLE public.evolucoes DROP CONSTRAINT evolucoes_prontuario_id_fkey;
                END IF;
            END $$;
        ");

        // Limpeza única de pacientes, agendamentos e dados vinculados (mantém usuários e clínicas).
        context.Database.ExecuteSqlRaw(@"
            CREATE TABLE IF NOT EXISTS public.system_maintenance_log (
                key text PRIMARY KEY,
                executed_at timestamp with time zone NOT NULL DEFAULT now()
            );

            DO $$
            DECLARE
                tbl text;
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM public.system_maintenance_log
                    WHERE key = 'clear_patients_and_appointments_20261126'
                ) THEN
                    FOREACH tbl IN ARRAY ARRAY[
                        'public.agendamentos',
                        'public.lista_espera',
                        'public.patient_change_logs',
                        'public.anamneses',
                        'public.anexos',
                        'public.""Attachments""',
                        'public.evolucoes',
                        'public.prontuarios',
                        'public.atestados',
                        'public.""MedicalRecords""',
                        'public.odontogramas',
                        'public.receitas',
                        'public.""TreatmentItems""',
                        'public.pacientes'
                    ] LOOP
                        IF to_regclass(tbl) IS NOT NULL THEN
                            EXECUTE 'TRUNCATE TABLE ' || tbl || ' RESTART IDENTITY CASCADE';
                        END IF;
                    END LOOP;

                    INSERT INTO public.system_maintenance_log (key)
                    VALUES ('clear_patients_and_appointments_20261126');
                END IF;
            END $$;
        ");

        try
        {
            var testPatients = await context.Patients
                .Where(p => p.FullName.ToLower().Replace(" ", "").Contains("testecadastro"))
                .Select(p => new { p.Id, p.FullName })
                .ToListAsync();

            if (testPatients.Count > 0)
            {
                var patientRepo = services.GetRequiredService<IPatientRepository>();
                foreach (var testPatient in testPatients)
                {
                    await patientRepo.DeleteAsync(testPatient.Id);
                    Console.WriteLine($">>> Paciente de teste removido na inicialização: {testPatient.FullName} ({testPatient.Id})");
                }
            }
        }
        catch (Exception cleanupEx)
        {
            Console.WriteLine($">>> AVISO ao remover paciente de teste: {cleanupEx.Message}");
        }

        var defaultClinicNames = new[]
        {
            "Clinica I",
            "Clinica II",
            "Clinica III",
            "Clinica IV",
            "Clinica V",
            "Clinica Integrada Infantil",
            "Clinica de Emergência",
            "Clinica Integrada Adulto I",
            "Clinica Integrada Adulto II",
            "Clinica de DTM",
            "Clinica de Odontopediatria"
        };

        static string NormalizeClinicName(string? name)
        {
            if (string.IsNullOrWhiteSpace(name)) return string.Empty;
            var decomposed = name.Trim().Normalize(NormalizationForm.FormD);
            var sb = new StringBuilder(decomposed.Length);
            foreach (var ch in decomposed)
            {
                if (System.Globalization.CharUnicodeInfo.GetUnicodeCategory(ch) != System.Globalization.UnicodeCategory.NonSpacingMark)
                {
                    sb.Append(char.ToLowerInvariant(ch));
                }
            }
            return System.Text.RegularExpressions.Regex.Replace(sb.ToString(), @"\s+", " ");
        }

        try
        {
            var allClinics = await context.Clinics.AsNoTracking().ToListAsync();
            var defaultNameSet = new HashSet<string>(defaultClinicNames, StringComparer.Ordinal);
            var duplicateGroups = allClinics
                .GroupBy(c => NormalizeClinicName(c.Name), StringComparer.Ordinal)
                .Where(g => !string.IsNullOrEmpty(g.Key) && g.Count() > 1)
                .ToList();

            if (duplicateGroups.Count > 0)
            {
                var conn = context.Database.GetDbConnection();
                if (conn.State != System.Data.ConnectionState.Open)
                {
                    await conn.OpenAsync();
                }

                var clinicRefColumns = new List<(string TableName, string ColumnName)>();
                await using (var metaCmd = conn.CreateCommand())
                {
                    metaCmd.CommandText = @"
                        SELECT DISTINCT table_name, column_name
                        FROM information_schema.columns
                        WHERE table_schema = 'public'
                          AND table_name <> 'clinicas'
                          AND data_type = 'uuid'
                          AND lower(column_name) IN ('clinica_id', 'clinicaid', 'clinic_id', 'clinicid');";
                    await using var reader = await metaCmd.ExecuteReaderAsync();
                    while (await reader.ReadAsync())
                    {
                        clinicRefColumns.Add((reader.GetString(0), reader.GetString(1)));
                    }
                }

                foreach (var group in duplicateGroups)
                {
                    var keeper = group
                        .OrderByDescending(c => c.IsActive)
                        .ThenBy(c => defaultNameSet.Contains(c.Name) ? 0 : 1)
                        .ThenBy(c => c.CreatedAt)
                        .First();

                    foreach (var dup in group.Where(c => c.Id != keeper.Id))
                    {
                        foreach (var (tbl, col) in clinicRefColumns)
                        {
                            await using var updCmd = conn.CreateCommand();
                            var pKeeper = updCmd.CreateParameter();
                            pKeeper.ParameterName = "@keeper";
                            pKeeper.Value = keeper.Id;
                            updCmd.Parameters.Add(pKeeper);
                            var pDup = updCmd.CreateParameter();
                            pDup.ParameterName = "@dup";
                            pDup.Value = dup.Id;
                            updCmd.Parameters.Add(pDup);

                            var qTbl = "\"" + tbl.Replace("\"", "\"\"") + "\"";
                            var qCol = "\"" + col.Replace("\"", "\"\"") + "\"";
                            updCmd.CommandText = $"UPDATE \"public\".{qTbl} SET {qCol} = @keeper WHERE {qCol} = @dup;";
                            await updCmd.ExecuteNonQueryAsync();
                        }

                        await using var delCmd = conn.CreateCommand();
                        var pDel = delCmd.CreateParameter();
                        pDel.ParameterName = "@dup";
                        pDel.Value = dup.Id;
                        delCmd.Parameters.Add(pDel);
                        delCmd.CommandText = "DELETE FROM \"public\".\"clinicas\" WHERE \"id\" = @dup;";
                        await delCmd.ExecuteNonQueryAsync();

                        Console.WriteLine($">>> Clínica duplicada removida: {dup.Name} ({dup.Id}) -> mantida {keeper.Name} ({keeper.Id})");
                    }
                }
            }
        }
        catch (Exception dedupEx)
        {
            Console.WriteLine($">>> AVISO ao deduplicar clínicas: {dedupEx.Message}");
        }

        var existingNormalizedClinics = new HashSet<string>(
            (await context.Clinics.AsNoTracking().Select(c => c.Name).ToListAsync())
                .Select(NormalizeClinicName),
            StringComparer.Ordinal);

        foreach (var clinicName in defaultClinicNames)
        {
            var normalized = NormalizeClinicName(clinicName);
            if (!existingNormalizedClinics.Contains(normalized))
            {
                context.Clinics.Add(Clinic.CreateBasic(clinicName, "Clínica Escola", 1, 8, 18));
                existingNormalizedClinics.Add(normalized);
            }
        }
        await context.SaveChangesAsync();

        // Migra agendamentos/registros vinculados a IDs legados (UUIDv5 determinístico do app)
        // ou clínicas-fantasma ("Clínica selecionada") para o ID real da clínica correspondente.
        try
        {
            var legacyDeterministicClinics = new Dictionary<Guid, string>
            {
                [Guid.Parse("d502762e-ea17-58c8-a6f1-c6411b2fc980")] = "Clinica I",
                [Guid.Parse("60a9416e-1abd-57d5-9f47-fa96c248e9b8")] = "Clinica II",
                [Guid.Parse("290d2cd7-1c89-573b-a963-22a7ab246a4d")] = "Clinica III",
                [Guid.Parse("6b26aa0d-aa35-5ce6-af4b-425473ad9cae")] = "Clinica IV",
                [Guid.Parse("d4d1d4be-420e-5e7e-aa97-3e0f3a10dbfd")] = "Clinica V",
                [Guid.Parse("5b634cc2-2e86-5dd6-8087-65083457185a")] = "Clinica Integrada Infantil",
                [Guid.Parse("4c63ead2-3450-5e19-abe9-d4bfd2cbc048")] = "Clinica de Emergência",
                [Guid.Parse("5c2d2861-af19-5b42-960b-e733383c2005")] = "Clinica Integrada Adulto I",
                [Guid.Parse("c51bd540-63b7-55ac-a5b3-3dff10456bc7")] = "Clinica Integrada Adulto II",
                [Guid.Parse("a1c3ab4d-0cc3-57c4-8959-5104e5265ec1")] = "Clinica de DTM",
                [Guid.Parse("c4a77fa1-57e0-5685-b28c-a0ef2193f222")] = "Clinica de Odontopediatria"
            };

            var canonicalClinics = await context.Clinics.AsNoTracking().ToListAsync();
            var conn = context.Database.GetDbConnection();
            if (conn.State != System.Data.ConnectionState.Open)
            {
                await conn.OpenAsync();
            }

            var refCols = new List<(string TableName, string ColumnName)>();
            await using (var metaCmd = conn.CreateCommand())
            {
                metaCmd.CommandText = @"
                    SELECT DISTINCT table_name, column_name
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                      AND table_name <> 'clinicas'
                      AND data_type = 'uuid'
                      AND lower(column_name) IN ('clinica_id', 'clinicaid', 'clinic_id', 'clinicid');";
                await using var reader = await metaCmd.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    refCols.Add((reader.GetString(0), reader.GetString(1)));
                }
            }

            foreach (var (legacyId, targetName) in legacyDeterministicClinics)
            {
                var targetKey = NormalizeClinicName(targetName);
                var canonical = canonicalClinics.FirstOrDefault(c =>
                    c.Id != legacyId && NormalizeClinicName(c.Name) == targetKey);
                if (canonical == null) continue;

                var movedRows = 0;
                foreach (var (tbl, col) in refCols)
                {
                    await using var updCmd = conn.CreateCommand();
                    var pCanonical = updCmd.CreateParameter();
                    pCanonical.ParameterName = "@canonical";
                    pCanonical.Value = canonical.Id;
                    updCmd.Parameters.Add(pCanonical);
                    var pLegacy = updCmd.CreateParameter();
                    pLegacy.ParameterName = "@legacy";
                    pLegacy.Value = legacyId;
                    updCmd.Parameters.Add(pLegacy);

                    var qTbl = "\"" + tbl.Replace("\"", "\"\"") + "\"";
                    var qCol = "\"" + col.Replace("\"", "\"\"") + "\"";
                    updCmd.CommandText = $"UPDATE \"public\".{qTbl} SET {qCol} = @canonical WHERE {qCol} = @legacy;";
                    movedRows += await updCmd.ExecuteNonQueryAsync();
                }

                await using var delCmd = conn.CreateCommand();
                var pDel = delCmd.CreateParameter();
                pDel.ParameterName = "@legacy";
                pDel.Value = legacyId;
                delCmd.Parameters.Add(pDel);
                delCmd.CommandText = "DELETE FROM \"public\".\"clinicas\" WHERE \"id\" = @legacy;";
                var deletedClinics = await delCmd.ExecuteNonQueryAsync();

                if (movedRows > 0 || deletedClinics > 0)
                {
                    Console.WriteLine($">>> Migrados {movedRows} registro(s) do ID legado {legacyId} para {canonical.Name} ({canonical.Id}).");
                }
            }
        }
        catch (Exception legacyClinicEx)
        {
            Console.WriteLine($">>> AVISO ao migrar clínicas legadas: {legacyClinicEx.Message}");
        }

        var adminEmail = "admin@odontoclinica.edu.br";
        // Cria usuário sem usar Address para evitar erro de mapeamento
        var user = await context.Users.FirstOrDefaultAsync(u => u.EmailAddress.Value == adminEmail);

        if (user == null)
        {
            user = User.Create(
                name: "Administrador Inicial",
                email: adminEmail,
                cpf: "",
                dateOfBirth: null,
                phone: null,
                address: null, // Passa null para Address
                role: DentalClinic.Core.Domain.Entities.UserRole.Admin
            );
            user.SetPasswordHash(hasher.HashPassword("admin123"));
            user.ConfirmEmail();
            user.Activate();
            context.Users.Add(user);
        }
        else
        {
            user.SetPasswordHash(hasher.HashPassword("admin123"));
            user.Activate();
            context.Users.Update(user);
        }

        await context.SaveChangesAsync();
        // MENSAGEM IMPORTANTE NO CONSOLE
        Console.WriteLine("**************************************************");
        Console.WriteLine(">>> BACKEND PRONTO!");
        Console.WriteLine($">>> LOGIN: {adminEmail}");
        Console.WriteLine(">>> SENHA: admin123");
        Console.WriteLine(">>> SWAGGER: http://localhost:5000/swagger");
        Console.WriteLine("**************************************************");

    } catch (Exception ex) {
        Console.WriteLine($">>> ERRO CRÍTICO NO SEED: {ex.Message}");
    }
}

app.Run();
