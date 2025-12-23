using System.ComponentModel.DataAnnotations;

namespace AIDungeonBackend.Models;

public class SessionMessage
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid SessionId { get; set; }
    
    [System.Text.Json.Serialization.JsonIgnore]
    public StorySession? Session { get; set; }

    [Required]
    [MaxLength(20)]
    public string Role { get; set; } = "player"; // player, dm, system

    [Required]
    public string Content { get; set; } = string.Empty;

    public int? TokenCount { get; set; }

    public string? Hint { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
