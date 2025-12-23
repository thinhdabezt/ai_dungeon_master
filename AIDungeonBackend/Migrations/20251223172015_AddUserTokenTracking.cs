using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AIDungeonBackend.Migrations
{
    /// <inheritdoc />
    public partial class AddUserTokenTracking : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "DailyTokenUsage",
                table: "Users",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "LastTokenReset",
                table: "Users",
                type: "TEXT",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DailyTokenUsage",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "LastTokenReset",
                table: "Users");
        }
    }
}
