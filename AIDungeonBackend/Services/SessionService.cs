using AIDungeonBackend.Data;
using AIDungeonBackend.Models;
using Microsoft.EntityFrameworkCore;

namespace AIDungeonBackend.Services;

public class SessionService : ISessionService
{
    private readonly ApplicationDbContext _context;

    public SessionService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<StorySession> CreateSessionAsync(Guid userId, string title, string themeKey)
    {
        var theme = await _context.Themes.FirstOrDefaultAsync(t => t.Key == themeKey);
        if (theme == null)
        {
            throw new ArgumentException($"Theme with key '{themeKey}' not found.");
        }

        var session = new StorySession
        {
            UserId = userId,
            ThemeId = theme.Id,
            Title = title,
            // Theme fetched here can be used if we need immediate access, 
            // but setting ThemeId is sufficient for EFFK
        };

        _context.StorySessions.Add(session);
        await _context.SaveChangesAsync();
        
        // Reload to get navigation properties if needed, or simply return
        // We might want to return Included data? 
        return session;
    }

    public async Task<List<StorySession>> GetSessionsAsync(Guid userId, int page, int pageSize)
    {
        return await _context.StorySessions
            .Where(s => s.UserId == userId)
            .OrderByDescending(s => s.LastUpdated)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Include(s => s.Theme)
            .ToListAsync();
    }

    public async Task<StorySession?> GetSessionAsync(Guid sessionId, Guid userId)
    {
        return await _context.StorySessions
            .Include(s => s.Theme)
            .Include(s => s.Messages.OrderByDescending(m => m.CreatedAt).Take(50)) // Load last 50 messages
            .FirstOrDefaultAsync(s => s.Id == sessionId && s.UserId == userId);
    }

    public async Task<SessionMessage> AddUserMessageAsync(Guid sessionId, Guid userId, string content)
    {
        // Verify ownership
        var session = await _context.StorySessions.FirstOrDefaultAsync(s => s.Id == sessionId && s.UserId == userId);
        if (session == null) throw new KeyNotFoundException("Session not found or access denied.");

        var message = new SessionMessage
        {
            SessionId = sessionId,
            Role = "player",
            Content = content
        };

        _context.SessionMessages.Add(message);
        
        // Update session LastUpdated
        session.LastUpdated = DateTime.UtcNow;
        
        await _context.SaveChangesAsync();
        return message;
    }

    public async Task<SessionMessage> AddDmMessageAsync(Guid sessionId, string content)
    {
         var message = new SessionMessage
        {
            SessionId = sessionId,
            Role = "dm",
            Content = content
        };

        _context.SessionMessages.Add(message);
        await _context.SaveChangesAsync();
        return message;
    }

    public async Task DeleteSessionAsync(Guid sessionId, Guid userId)
    {
        var session = await _context.StorySessions.FirstOrDefaultAsync(s => s.Id == sessionId && s.UserId == userId);
        if (session != null)
        {
            _context.StorySessions.Remove(session);
            await _context.SaveChangesAsync();
        }
    }
}
