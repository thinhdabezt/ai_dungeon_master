using System.ComponentModel.DataAnnotations;

namespace AiDungeonMaster.Api.Models
{
    public class Player
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = "";

        //public string? Email { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // 1-n relationship: Player has many sessions
        public List<StorySession> Sessions { get; set; } = new();
    }
}
