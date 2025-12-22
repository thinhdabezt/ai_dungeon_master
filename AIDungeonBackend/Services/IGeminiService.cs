using AIDungeonBackend.Models;

namespace AIDungeonBackend.Services;

public interface IGeminiService
{
    Task<string> GenerateContentAsync(string systemPrompt, List<SessionMessage> history, string newUserInput);
}
