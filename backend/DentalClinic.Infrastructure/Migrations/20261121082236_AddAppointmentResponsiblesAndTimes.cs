using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DentalClinic.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddAppointmentResponsiblesAndTimes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "ActualEndTime",
                table: "agendamentos",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ActualStartTime",
                table: "agendamentos",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ArrivalTime",
                table: "agendamentos",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "ProfessorId",
                table: "agendamentos",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ProfessorName",
                table: "agendamentos",
                type: "text",
                nullable: true);

            migrationBuilder.Sql("UPDATE \"agendamentos\" SET \"Status\" = CASE \"Status\" WHEN 3 THEN 4 WHEN 4 THEN 5 WHEN 5 THEN 6 WHEN 6 THEN 8 ELSE \"Status\" END;");

            migrationBuilder.AddColumn<Guid>(
                name: "StudentId",
                table: "agendamentos",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "StudentName",
                table: "agendamentos",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("UPDATE \"agendamentos\" SET \"Status\" = CASE \"Status\" WHEN 4 THEN 3 WHEN 5 THEN 4 WHEN 6 THEN 5 WHEN 8 THEN 6 ELSE \"Status\" END;");

            migrationBuilder.DropColumn(
                name: "ActualEndTime",
                table: "agendamentos");

            migrationBuilder.DropColumn(
                name: "ActualStartTime",
                table: "agendamentos");

            migrationBuilder.DropColumn(
                name: "ArrivalTime",
                table: "agendamentos");

            migrationBuilder.DropColumn(
                name: "ProfessorId",
                table: "agendamentos");

            migrationBuilder.DropColumn(
                name: "ProfessorName",
                table: "agendamentos");

            migrationBuilder.DropColumn(
                name: "StudentId",
                table: "agendamentos");

            migrationBuilder.DropColumn(
                name: "StudentName",
                table: "agendamentos");
        }
    }
}
