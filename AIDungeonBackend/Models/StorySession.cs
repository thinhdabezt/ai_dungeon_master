using System.ComponentModel.DataAnnotations;

namespace AIDungeonBackend.Models;

public class StorySession
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid UserId { get; set; }
    public User? User { get; set; }

    public int ThemeId { get; set; }
    public Theme? Theme { get; set; }

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    public bool IsPinned { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime LastUpdated { get; set; } = DateTime.UtcNow;

    public ICollection<SessionMessage> Messages { get; set; } = new List<SessionMessage>();
}
