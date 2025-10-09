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

        public string? PasswordHash { get; set; }  // NEW

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public List<StorySession> Sessions { get; set; } = new();
    }
}
