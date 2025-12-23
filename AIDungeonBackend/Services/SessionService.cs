using AIDungeonBackend.Data;
using AIDungeonBackend.Models;
using Microsoft.EntityFrameworkCore;

namespace AIDungeonBackend.Services;

public class SessionService : ISessionService
{
    private readonly ApplicationDbContext _context;
    private readonly IGeminiService _geminiService;

    public SessionService(ApplicationDbContext context, IGeminiService geminiService)
    {
        _context = context;
        _geminiService = geminiService;
    }




    public async Task<SessionMessage> ProcessChatAsync(Guid sessionId, Guid userId, string playerInput, bool includeHint = false)
    {
        // 1. Check user settings if includeHint is explicitly requested OR defaults to user preference
        // Requirement: "Chat endpoint accepts includeHint boolean". We will trust the controller/parameter.
        // We could also auto-enable if user settings say so, but usually frontend drives the "per request" logic based on settings.
        // Let's assume the controller passed the resolved boolean.

        // 2. Add User Message
        await AddUserMessageAsync(sessionId, userId, playerInput);

        // 3. Fetch Session & History
        var session = await _context.StorySessions
            .Include(s => s.Theme)
            .Include(s => s.Messages.OrderByDescending(m => m.CreatedAt).Take(10)) 
            .FirstOrDefaultAsync(s => s.Id == sessionId && s.UserId == userId);

        if (session == null) throw new KeyNotFoundException("Session not found.");
        if (session.Theme == null) throw new InvalidOperationException("Session has no theme.");

        // 4. Prepare History
        var history = session.Messages.OrderBy(m => m.CreatedAt).ToList();
        var historyForAi = history.Where(m => m.Content != playerInput || m.Role != "player").ToList(); 
        if (history.Any() && history.Last().Role == "player" && history.Last().Content == playerInput)
        {
            historyForAi = history.Take(history.Count - 1).ToList();
        }
        else 
        {
            historyForAi = history; 
        }

        // 5. Construct System Prompt (with Hint instruction if needed)
        var systemPrompt = session.Theme.PersonaPrompt;
        if (includeHint)
        {
            systemPrompt += "\n\n[INSTRUCTION]: You must also provide a short, helpful hint for the player's next move. " +
                            "Output the hint at the very end of your response, wrapped in <hint>...</hint> tags. " +
                            "Do not mention the hint in the main story text.";
        }

        // 6. Call AI
        var rawResponse = await _geminiService.GenerateContentAsync(systemPrompt, historyForAi, playerInput);

        // 7. Parse Response (Extract Hint)
        string storyContent = rawResponse;
        string? hintContent = null;

        if (includeHint && rawResponse.Contains("<hint>"))
        {
            var start = rawResponse.IndexOf("<hint>") + "<hint>".Length;
            var end = rawResponse.IndexOf("</hint>");
            if (end > start)
            {
                hintContent = rawResponse.Substring(start, end - start).Trim();
                // Remove hint tags and content from story
                string beforeHint = rawResponse.Substring(0, rawResponse.IndexOf("<hint>"));
                string afterHint = rawResponse.Substring(end + "</hint>".Length);
                storyContent = (beforeHint + afterHint).Trim();
            }
        }

        // 8. Persist DM Response
        var dmMessage = await AddDmMessageAsync(sessionId, storyContent, hintContent);

        return dmMessage;
    }

    // ... existing CreateSessionAsync ...
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
        };

        _context.StorySessions.Add(session);
        await _context.SaveChangesAsync();
        
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
            .Include(s => s.Messages.OrderByDescending(m => m.CreatedAt).Take(50))
            .FirstOrDefaultAsync(s => s.Id == sessionId && s.UserId == userId);
    }

    public async Task<SessionMessage> AddUserMessageAsync(Guid sessionId, Guid userId, string content)
    {
        var session = await _context.StorySessions.FirstOrDefaultAsync(s => s.Id == sessionId && s.UserId == userId);
        if (session == null) throw new KeyNotFoundException("Session not found or access denied.");

        var message = new SessionMessage
        {
            SessionId = sessionId,
            Role = "player",
            Content = content
        };

        _context.SessionMessages.Add(message);
        session.LastUpdated = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        return message;
    }

    public async Task<SessionMessage> AddDmMessageAsync(Guid sessionId, string content)
    {
        return await AddDmMessageAsync(sessionId, content, null);
    }

    private async Task<SessionMessage> AddDmMessageAsync(Guid sessionId, string content, string? hint)
    {
         var message = new SessionMessage
        {
            SessionId = sessionId,
            Role = "dm",
            Content = content,
            Hint = hint
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
