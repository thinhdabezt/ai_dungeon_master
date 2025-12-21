using System.ComponentModel.DataAnnotations;

namespace AIDungeonBackend.Models;

public class Theme
{
    public int Id { get; set; }

    [Required]
    [MaxLength(50)]
    public string Key { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [Required]
    public string PersonaPrompt { get; set; } = string.Empty;

    public float Temperature { get; set; } = 0.7f;
    
    public int MaxTokens { get; set; } = 1024;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
