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
    }
}
