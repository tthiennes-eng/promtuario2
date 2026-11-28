using DentalClinic.Core.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DentalClinic.Infrastructure.Persistence.Configurations;

public class PatientConfiguration : IEntityTypeConfiguration<Patient>
{
    public void Configure(EntityTypeBuilder<Patient> builder)
    {
        builder.ToTable("pacientes");

        builder.HasKey(p => p.Id);
        builder.Property(p => p.Id).HasColumnName("id");

        builder.Property(p => p.FullName)
            .HasColumnName("nome_completo")
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(p => p.SocialName)
            .HasColumnName("nome_social")
            .HasMaxLength(255);

        builder.Property(p => p.CPF)
            .HasColumnName("cpf")
            .IsRequired()
            .HasMaxLength(14);

        builder.HasIndex(p => p.CPF).IsUnique();

        builder.Property(p => p.SusNumber)
            .HasColumnName("numero_sus")
            .HasMaxLength(15);

        builder.Property(p => p.Email)
            .HasColumnName("email")
            .HasMaxLength(255);

        builder.Property(p => p.Phone)
            .HasColumnName("telefone")
            .HasMaxLength(20);

        // CORREÇÃO: Email e Telefone são opcionais (string? na entidade, sem
        // IsRequired()). Em bancos legados criados com NOT NULL por migrações
        // antigas, o seed de Program.cs executa ALTER TABLE ... DROP NOT NULL
        // nas colunas email/telefone para manter o schema consistente.

        builder.Property(p => p.BirthDate)
            .HasColumnName("data_nascimento")
            .IsRequired();

        builder.Property(p => p.Gender)
            .HasColumnName("sexo")
            .HasMaxLength(1);

        // Mapeamento de Endereço (Objeto C# -> Colunas normais)
        // Configurado no ApplicationDbContext.OnModelCreating via OwnsOne

        builder.Property(p => p.LgpdConsent)
            .HasColumnName("consentimento_lgpd")
            .HasDefaultValue(false);

        builder.Property(p => p.CreatedAt).HasColumnName("criado_em");
        builder.Property(p => p.UpdatedAt).HasColumnName("atualizado_em");
        
        // Campo para sincronização entre dispositivos
        builder.Property(p => p.LastModifiedAt)
            .HasColumnName("ultima_modificacao")
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(p => p.IsActive)
            .HasColumnName("ativo")
            .HasDefaultValue(true);

        builder.HasIndex(p => p.FullName);
        builder.HasIndex(p => p.LastModifiedAt);
    }
}
