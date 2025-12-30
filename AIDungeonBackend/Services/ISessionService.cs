using AIDungeonBackend.Models;

namespace AIDungeonBackend.Services;

public interface ISessionService
{
    Task<StorySession> CreateSessionAsync(Guid userId, string title, string themeKey, string ieltsBand);
    Task<List<StorySession>> GetSessionsAsync(Guid userId, int page, int pageSize);
    Task<StorySession?> GetSessionAsync(Guid sessionId, Guid userId);
    Task<SessionMessage> AddUserMessageAsync(Guid sessionId, Guid userId, string content);
    Task<SessionMessage> AddDmMessageAsync(Guid sessionId, string content);
    Task<SessionMessage> ProcessChatAsync(Guid sessionId, Guid userId, string playerInput, bool includeHint = false);
    Task DeleteSessionAsync(Guid sessionId, Guid userId);
    Task RenameSessionAsync(Guid sessionId, Guid userId, string newTitle);
}
