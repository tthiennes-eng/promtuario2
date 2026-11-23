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

app.UseStaticFiles();
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
            -- "O paciente selecionado não existe no servidor."
            ALTER TABLE IF EXISTS pacientes
                ALTER COLUMN email DROP NOT NULL,
                ALTER COLUMN telefone DROP NOT NULL;

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

        foreach (var clinicName in defaultClinicNames)
        {
            var exists = await context.Clinics.AnyAsync(c => c.Name == clinicName);
            if (!exists)
            {
                context.Clinics.Add(Clinic.CreateBasic(clinicName, "Clínica Escola", 1, 8, 18));
            }
        }
        await context.SaveChangesAsync();

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
