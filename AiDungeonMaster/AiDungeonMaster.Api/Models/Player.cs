using System.ComponentModel.DataAnnotations;

namespace AiDungeonMaster.Api.Models
{
    public class Player
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = "";

        public string? Email { get; set; }

        // hashed password (nullable if OAuth)
        public string? PasswordHash { get; set; }

        // role: "User" or "Admin"
        public string Role { get; set; } = "User";

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // navigation
        public List<StorySession> Sessions { get; set; } = new();
    }
}
