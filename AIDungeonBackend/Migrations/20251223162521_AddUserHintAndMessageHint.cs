using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AIDungeonBackend.Migrations
{
    /// <inheritdoc />
    public partial class AddUserHintAndMessageHint : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "HintEnabled",
                table: "Users",
                type: "INTEGER",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "Hint",
                table: "SessionMessages",
                type: "TEXT",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "HintEnabled",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "Hint",
                table: "SessionMessages");
        }
    }
}
