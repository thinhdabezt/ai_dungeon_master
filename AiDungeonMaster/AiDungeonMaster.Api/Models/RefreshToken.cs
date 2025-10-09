using System.ComponentModel.DataAnnotations;

namespace AiDungeonMaster.Api.Models
{
    public class RefreshToken
    {
        [Key]
        public int Id { get; set; }

        public string TokenHash { get; set; } = "";
        public string JwtId { get; set; } = "";
        public int PlayerId { get; set; }
        public Player? Player { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime ExpiresAt { get; set; }
        public bool Revoked { get; set; } = false;
        public string? RemoteIpAddress { get; set; }
    }
}
