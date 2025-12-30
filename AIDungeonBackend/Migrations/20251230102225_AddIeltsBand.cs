using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AIDungeonBackend.Migrations
{
    /// <inheritdoc />
    public partial class AddIeltsBand : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "IeltsBand",
                table: "StorySessions",
                type: "TEXT",
                maxLength: 10,
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IeltsBand",
                table: "StorySessions");
        }
    }
}
