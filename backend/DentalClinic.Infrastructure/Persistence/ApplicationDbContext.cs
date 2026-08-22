using Microsoft.EntityFrameworkCore;
using DentalClinic.Core.Domain.Entities;
using System.Reflection;

namespace DentalClinic.Infrastructure.Persistence;

/// <summary>
/// Contexto principal do Banco de Dados PostgreSQL.
/// Implementa o padrão Data Mapper através do EF Core.
/// </summary>
public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Patient> Patients => Set<Patient>();
    public DbSet<Clinic> Clinics => Set<Clinic>();
    public DbSet<Appointment> Appointments => Set<Appointment>();
    public DbSet<Evolution> Evolutions => Set<Evolution>();
    public DbSet<Odontogram> Odontograms => Set<Odontogram>();
    public DbSet<Anexo> Anexos => Set<Anexo>();
    public DbSet<Prescription> Prescriptions => Set<Prescription>();
    public DbSet<MedicalCertificate> Certificates => Set<MedicalCertificate>();
    public DbSet<Anamnese> Anamneses => Set<Anamnese>();
    public DbSet<UserSession> UserSessions => Set<UserSession>();
    public DbSet<LogAuditoria> LogsAuditoria => Set<LogAuditoria>();
    public DbSet<MedicalRecord> MedicalRecords => Set<MedicalRecord>();
    public DbSet<Attachment> Attachments => Set<Attachment>();
    public DbSet<TreatmentItem> TreatmentItems => Set<TreatmentItem>();
    public DbSet<WaitListEntry> WaitListEntries => Set<WaitListEntry>();
    public DbSet<PatientChangeLog> PatientChangeLogs => Set<PatientChangeLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Aplica automaticamente todas as configurações que implementam IEntityTypeConfiguration
        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

        // Configura Address como tipo sem chave (Value Object) para Patient
        modelBuilder.Entity<Patient>()
            .OwnsOne(p => p.Address, addressBuilder =>
            {
                addressBuilder.Property(a => a.Street).HasColumnName("endereco_rua");
                addressBuilder.Property(a => a.Number).HasColumnName("endereco_numero");
                addressBuilder.Property(a => a.Complement).HasColumnName("endereco_complemento");
                addressBuilder.Property(a => a.Neighborhood).HasColumnName("endereco_bairro");
                addressBuilder.Property(a => a.City).HasColumnName("endereco_cidade");
                addressBuilder.Property(a => a.State).HasColumnName("endereco_estado");
                addressBuilder.Property(a => a.ZipCode).HasColumnName("endereco_cep");
            });

        // Ignora Address em User pois está marcado como [NotMapped]
        modelBuilder.Entity<User>()
            .Ignore(u => u.Address);

        // Configurações Adicionais para tipos complexos ou relacionamentos
        modelBuilder.Entity<Odontogram>()
            .Property(o => o.Teeth)
            .HasColumnType("jsonb");

        modelBuilder.Entity<Prescription>()
            .Property(p => p.Items)
            .HasColumnType("jsonb");

        modelBuilder.Entity<Anamnese>()
            .Property(a => a.RespostasJson)
            .HasColumnType("jsonb");

        base.OnModelCreating(modelBuilder);
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        foreach (var entry in ChangeTracker.Entries<Entity>())
        {
            if (entry.State == EntityState.Added)
            {
                entry.Entity.CreatedAt = DateTime.UtcNow;
            }
            if (entry.State == EntityState.Modified)
            {
                entry.Entity.UpdatedAt = DateTime.UtcNow;
            }
        }

        return base.SaveChangesAsync(cancellationToken);
    }
}
