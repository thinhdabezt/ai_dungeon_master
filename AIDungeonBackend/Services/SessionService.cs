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



    public async Task<SessionMessage> ProcessChatAsync(Guid sessionId, Guid userId, string playerInput)
    {
        // 1. Add User Message
        await AddUserMessageAsync(sessionId, userId, playerInput);

        // 2. Fetch Session & History (Configurable K=10)
        var session = await _context.StorySessions
            .Include(s => s.Theme)
            .Include(s => s.Messages.OrderByDescending(m => m.CreatedAt).Take(10)) 
            .FirstOrDefaultAsync(s => s.Id == sessionId && s.UserId == userId);

        if (session == null) throw new KeyNotFoundException("Session not found.");
        if (session.Theme == null) throw new InvalidOperationException("Session has no theme.");

        // 3. Prepare Prompt
        // History comes in reverse order (e.g., [Newest, ..., Oldest])
        // We need chronological order for the LLM: [Oldest, ..., Newest]
        // Note: The playerInput is already in DB (step 1), so it's in session.Messages[0] (or close to it)
        // However, we just added it. Let's rely on the DB fetch to get it, or simpler:
        // We know playerInput is the latest. 
        // To be safe and consistent with the service method "AddUserMessage", let's use the fetched messages.
        
        var history = session.Messages.OrderBy(m => m.CreatedAt).ToList();
        
        // Remove the very last message if it's the one we just added (to avoid duplication if we pass input separately? 
        // Actually, IGeminiService.GenerateContentAsync takes (system, history, input).
        // If "input" is separate, we should exclude it from "history".
        // BUT, we just persisted it.
        // Let's adjust IGeminiService signature usage: 
        // We can pass the playerInput as the new input, and history as everything BEFORE it.
        
        var historyForAi = history.Where(m => m.Content != playerInput || m.Role != "player").ToList(); 
        // ^ This logic is flaky if user repeats text. 
        // Better: Identify by ID if possible, or just pass ALL history to a Modified IGeminiService that takes full history?
        // Let's stick to the interface: GenerateContentAsync(system, history, input).
        // We will exclude the *latest* message from history if it matches.
        // Actually, cleanest way: Pass history excluding the last player message, and pass playerInput as the argument.
        
        if (history.Any() && history.Last().Role == "player" && history.Last().Content == playerInput)
        {
            historyForAi = history.Take(history.Count - 1).ToList();
        }
        else 
        {
            // Should not happen if AddUserMessageAsync worked and we fetched sorted by CreatedAt
            historyForAi = history; 
        }

        // 4. Call AI
        var systemPrompt = session.Theme.PersonaPrompt;
        var dmResponseText = await _geminiService.GenerateContentAsync(systemPrompt, historyForAi, playerInput);

        // 5. Persist DM Response
        var dmMessage = await AddDmMessageAsync(sessionId, dmResponseText);

        return dmMessage;
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
