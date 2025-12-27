using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AIDungeonBackend.Models;

public class Flashcard
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid UserId { get; set; }
    
    // Navigation property - kept optional to avoid cycles in standard serializer if not handled, 
    // but usually specific DTOs are used. 
    [ForeignKey("UserId")]
    public User? User { get; set; }

    [Required]
    public string Word { get; set; } = string.Empty;

    [Required]
    public string Definition { get; set; } = string.Empty;
    
    public string? ContextSentence { get; set; }
    
    public Guid? SourceSessionId { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // SRS Fields for Milestone F7
    public DateTime? NextReviewDate { get; set; }
}
