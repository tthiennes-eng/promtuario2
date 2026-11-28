using DentalClinic.Core.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DentalClinic.Infrastructure.Persistence.Configurations;

public class ClinicConfiguration : IEntityTypeConfiguration<Clinic>
{
    public void Configure(EntityTypeBuilder<Clinic> builder)
    {
        builder.ToTable("clinicas");

        builder.HasKey(c => c.Id);
        builder.Property(c => c.Id).HasColumnName("id");

        builder.Property(c => c.Name).HasColumnName("nome").IsRequired().HasMaxLength(100);
        builder.Property(c => c.Description).HasColumnName("descricao");

        builder.Property(c => c.Specialty)
            .HasColumnName("especialidade")
            .HasConversion<int>();

        builder.Property(c => c.Location).HasColumnName("localizacao").HasMaxLength(255).HasDefaultValue("");
        builder.Property(c => c.MaxCapacity).HasColumnName("capacidade").HasDefaultValue(1);
        builder.Property(c => c.OpeningTime).HasColumnName("horario_abertura").HasMaxLength(10).HasDefaultValue("08:00");
        builder.Property(c => c.ClosingTime).HasColumnName("horario_fechamento").HasMaxLength(10).HasDefaultValue("18:00");
        builder.Property(c => c.SlotDurationMinutes).HasColumnName("duracao_slot_minutos").HasDefaultValue(60);

        builder.Property(c => c.IsActive).HasColumnName("ativo").HasDefaultValue(true);
        builder.Property(c => c.CreatedAt).HasColumnName("criado_em");
        builder.Property(c => c.UpdatedAt).HasColumnName("atualizado_em");

        // Ignora propriedades de Value Object / vínculo não presentes na tabela clinicas
        builder.Ignore(c => c.Address);
        builder.Ignore(c => c.CoordinatorUserId);
    }
}
