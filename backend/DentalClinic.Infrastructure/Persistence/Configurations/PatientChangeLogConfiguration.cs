using DentalClinic.Core.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DentalClinic.Infrastructure.Persistence.Configurations;

public class PatientChangeLogConfiguration : IEntityTypeConfiguration<PatientChangeLog>
{
    public void Configure(EntityTypeBuilder<PatientChangeLog> builder)
    {
        builder.ToTable("patient_change_logs");

        builder.HasKey(l => l.Id);
        builder.Property(l => l.Id).HasColumnName("id");

        builder.Property(l => l.PatientId)
            .HasColumnName("patient_id")
            .IsRequired();

        builder.Property(l => l.UserId)
            .HasColumnName("user_id")
            .IsRequired();

        builder.Property(l => l.UserName)
            .HasColumnName("user_name")
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(l => l.Timestamp)
            .HasColumnName("timestamp")
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(l => l.ChangesJson)
            .HasColumnName("changes_json")
            .HasColumnType("jsonb")
            .IsRequired();

        // Relacionamento com o paciente (apenas para navegação, sem cascade delete)
        builder.HasOne(l => l.Patient)
            .WithMany()
            .HasForeignKey(l => l.PatientId)
            .OnDelete(DeleteBehavior.Restrict);

        // Índice para busca eficiente por patient_id
        builder.HasIndex(l => l.PatientId);
        
        // Índice para ordenação por timestamp
        builder.HasIndex(l => new { l.PatientId, l.Timestamp });
    }
}
