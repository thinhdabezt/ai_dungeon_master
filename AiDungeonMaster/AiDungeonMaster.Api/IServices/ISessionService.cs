using AiDungeonMaster.Api.Models;

namespace AiDungeonMaster.Api.IServices
{
    public interface ISessionService
    {
        StorySession GetOrCreateSession(string? sessionId, string? themeKey, int playerId = 0);
        void AddExchange(string sessionId, string playerInput, string dmResponse);
        IEnumerable<string> GetFullContext(string sessionId);
    }
}
