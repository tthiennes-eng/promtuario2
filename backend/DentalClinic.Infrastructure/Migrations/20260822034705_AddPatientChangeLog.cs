using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DentalClinic.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPatientChangeLog : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_patient_change_logs_patient_id",
                table: "patient_change_logs",
                column: "patient_id");

            migrationBuilder.CreateIndex(
                name: "IX_patient_change_logs_patient_id_timestamp",
                table: "patient_change_logs",
                columns: new[] { "patient_id", "timestamp" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(name: "patient_change_logs");
        }
    }
}
