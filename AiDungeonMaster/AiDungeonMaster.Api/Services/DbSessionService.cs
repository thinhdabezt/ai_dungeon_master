using AiDungeonMaster.Api.Data;
using AiDungeonMaster.Api.IServices;
using AiDungeonMaster.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace AiDungeonMaster.Api.Services
{
    public class DbSessionService : ISessionService
    {
        private readonly AppDbContext _context;

        public DbSessionService(AppDbContext context)
        {
            _context = context;
        }

        public StorySession GetOrCreateSession(string? sessionId, string? themeKey, int playerId = 0)
        {
            if (string.IsNullOrEmpty(sessionId))
            {
                var newSession = new StorySession { ThemeKey = themeKey, PlayerId = playerId };
                _context.StorySessions.Add(newSession);
                _context.SaveChanges();
                return newSession;
            }

            var existing = _context.StorySessions
                .Include(s => s.Messages)
                .FirstOrDefault(s => s.SessionId == sessionId);

            if (existing != null)
                return existing;

            var created = new StorySession
            {
                SessionId = sessionId,
                ThemeKey = themeKey,
                PlayerId = playerId
            };

            _context.StorySessions.Add(created);
            _context.SaveChanges();
            return created;
        }


        public void AddExchange(string sessionId, string playerInput, string dmResponse)
        {
            var messages = new List<StoryMessage>
            {
                new StoryMessage { Role = "Player", Content = playerInput, SessionId = sessionId },
                new StoryMessage { Role = "DM", Content = dmResponse, SessionId = sessionId }
            };

            _context.StoryMessages.AddRange(messages);
            _context.SaveChanges();
        }

        public IEnumerable<string> GetFullContext(string sessionId)
        {
            var session = _context.StorySessions
                .Include(s => s.Messages)
                .FirstOrDefault(s => s.SessionId == sessionId);

            if (session == null) yield break;

            foreach (var msg in session.Messages.OrderBy(m => m.Id))
            {
                yield return $"{msg.Role}: {msg.Content}";
            }
        }
    }
}
