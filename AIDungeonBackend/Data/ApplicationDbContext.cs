using AIDungeonBackend.Models;
using Microsoft.EntityFrameworkCore;

namespace AIDungeonBackend.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }
    
    public DbSet<User> Users { get; set; }
    public DbSet<RefreshToken> RefreshTokens { get; set; }
    public DbSet<Theme> Themes { get; set; }
    public DbSet<StorySession> StorySessions { get; set; }
    public DbSet<SessionMessage> SessionMessages { get; set; }
    public DbSet<Flashcard> Flashcards { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<User>()
            .HasIndex(u => u.Username)
            .IsUnique();

        modelBuilder.Entity<User>()
            .HasIndex(u => u.Email)
            .IsUnique();

        modelBuilder.Entity<Theme>()
            .HasIndex(t => t.Key)
            .IsUnique();
    }
}
