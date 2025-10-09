using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AiDungeonMaster.Api.Models
{
    public class StorySession
    {
        [Key]
        public string SessionId { get; set; } = Guid.NewGuid().ToString();

        public string? ThemeKey { get; set; }

        // Foreign key to Player
        public int PlayerId { get; set; }
        public Player? Player { get; set; }

        public List<StoryMessage> Messages { get; set; } = new();
    }
}
