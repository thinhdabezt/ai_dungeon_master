using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AiDungeonMaster.Api.Models
{
    public class StoryMessage
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        public string Role { get; set; } = ""; // "Player" or "DM"
        public string Content { get; set; } = "";

        // Foreign Key
        public string SessionId { get; set; } = "";
        public StorySession? Session { get; set; }
    }
}
