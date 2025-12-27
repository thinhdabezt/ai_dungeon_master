using AIDungeonBackend.DTOs;
using AIDungeonBackend.Models;

namespace AIDungeonBackend.Services;

public interface IGeminiService
{
    Task<(string Content, int InputTokens, int OutputTokens)> GenerateContentAsync(string systemPrompt, List<SessionMessage> history, string newUserInput);
    Task<List<VocabularyExtractionDto>> ExtractVocabularyAsync(string text);
}
