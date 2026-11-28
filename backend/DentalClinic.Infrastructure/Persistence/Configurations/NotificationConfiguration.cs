using DentalClinic.Core.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DentalClinic.Infrastructure.Persistence.Configurations;

public class NotificationConfiguration : IEntityTypeConfiguration<Notification>
{
    public void Configure(EntityTypeBuilder<Notification> builder)
    {
        builder.ToTable("notificacoes");

        builder.HasKey(n => n.Id);
        builder.Property(n => n.Id).HasColumnName("id");
        builder.Property(n => n.UserId).HasColumnName("usuario_id").IsRequired();
        builder.Property(n => n.Title).HasColumnName("titulo").IsRequired().HasMaxLength(200);
        builder.Property(n => n.Message).HasColumnName("mensagem").IsRequired().HasMaxLength(2000);
        builder.Property(n => n.IsRead).HasColumnName("lida").HasDefaultValue(false);
        builder.Property(n => n.Type).HasColumnName("tipo").HasConversion<int>();
        builder.Property(n => n.RelatedEntityId).HasColumnName("entidade_relacionada_id").HasMaxLength(100);
        builder.Property(n => n.CreatedAt).HasColumnName("criado_em");
        builder.Property(n => n.UpdatedAt).HasColumnName("atualizado_em");

        builder.HasOne(n => n.User)
            .WithMany()
            .HasForeignKey(n => n.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(n => new { n.UserId, n.IsRead });
    }
}
