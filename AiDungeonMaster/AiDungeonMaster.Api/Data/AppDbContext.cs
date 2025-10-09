using Microsoft.EntityFrameworkCore;
using AiDungeonMaster.Api.Models;

namespace AiDungeonMaster.Api.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Player> Players => Set<Player>();
        public DbSet<StorySession> StorySessions => Set<StorySession>();
        public DbSet<StoryMessage> StoryMessages => Set<StoryMessage>();
        public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
        public DbSet<Theme> Themes => Set<Theme>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Player>()
                .HasMany(p => p.Sessions)
                .WithOne(s => s.Player)
                .HasForeignKey(s => s.PlayerId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<StorySession>()
                .HasMany(s => s.Messages)
                .WithOne(m => m.Session)
                .HasForeignKey(m => m.SessionId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Theme>().HasNoKey();

            base.OnModelCreating(modelBuilder);
        }
    }
}
