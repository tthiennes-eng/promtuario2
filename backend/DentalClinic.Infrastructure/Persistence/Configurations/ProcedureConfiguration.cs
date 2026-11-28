using DentalClinic.Core.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DentalClinic.Infrastructure.Persistence.Configurations;

public class ProcedureConfiguration : IEntityTypeConfiguration<Procedure>
{
    public void Configure(EntityTypeBuilder<Procedure> builder)
    {
        builder.ToTable("procedimentos");

        builder.HasKey(p => p.Id);
        builder.Property(p => p.Id).HasColumnName("id");
        builder.Property(p => p.Name).HasColumnName("nome").IsRequired().HasMaxLength(200);
        builder.Property(p => p.Code).HasColumnName("codigo").IsRequired().HasMaxLength(50);
        builder.Property(p => p.BaseValue).HasColumnName("valor_base").HasColumnType("numeric(12,2)").HasDefaultValue(0m);
        builder.Property(p => p.Specialty).HasColumnName("especialidade").HasConversion<int?>();
        builder.Property(p => p.EstimatedTimeMinutes).HasColumnName("tempo_estimado_minutos").HasDefaultValue(60);
        builder.Property(p => p.CreatedAt).HasColumnName("criado_em");
        builder.Property(p => p.UpdatedAt).HasColumnName("atualizado_em");

        builder.HasIndex(p => p.Code);
    }
}
