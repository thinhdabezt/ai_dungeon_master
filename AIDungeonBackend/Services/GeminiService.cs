using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using AIDungeonBackend.DTOs;
using AIDungeonBackend.Models;
using Microsoft.Extensions.Configuration;
using System.Net.Http;

namespace AIDungeonBackend.Services;

public class GeminiService : IGeminiService
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;

    public GeminiService(IHttpClientFactory httpClientFactory, IConfiguration configuration)
    {
        _httpClientFactory = httpClientFactory;
        _configuration = configuration;
    }

    public async Task<(string Content, int InputTokens, int OutputTokens)> GenerateContentAsync(string systemPrompt, List<SessionMessage> history, string newUserInput)
    {
        var apiKey = _configuration["Gemini:ApiKey"];
        var model = _configuration["Gemini:Model"] ?? "gemini-2.0-flash-lite";
        var url = $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";

        var contents = new List<object>();

        foreach (var msg in history)
        {
            var role = msg.Role == "player" ? "user" : "model";
            contents.Add(new
            {
                role = role,
                parts = new[] { new { text = msg.Content } }
            });
        }

        contents.Add(new
        {
            role = "user",
            parts = new[] { new { text = newUserInput } }
        });

        var requestBody = new
        {
            systemInstruction = new 
            {
                parts = new[] { new { text = systemPrompt } }
            },
            contents = contents,
            generationConfig = new
            {
                temperature = 0.7,
                maxOutputTokens = 1024
            }
        };

        var json = JsonSerializer.Serialize(requestBody);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        var client = _httpClientFactory.CreateClient("GeminiClient");
        var response = await client.PostAsync(url, content);

        if (!response.IsSuccessStatusCode)
        {
            var errorBody = await response.Content.ReadAsStringAsync();
            throw new HttpRequestException($"Gemini API Error: {response.StatusCode} - {errorBody}");
        }

        var responseString = await response.Content.ReadAsStringAsync();
        using var document = JsonDocument.Parse(responseString);
        
        try 
        {
            var text = document.RootElement
                .GetProperty("candidates")[0]
                .GetProperty("content")
                .GetProperty("parts")[0]
                .GetProperty("text")
                .GetString() ?? "";

            int promptTokens = 0;
            int candidatesTokens = 0;

            if (document.RootElement.TryGetProperty("usageMetadata", out var usage))
            {
                if (usage.TryGetProperty("promptTokenCount", out var pt)) promptTokens = pt.GetInt32();
                if (usage.TryGetProperty("candidatesTokenCount", out var ct)) candidatesTokens = ct.GetInt32();
            }
                
            return (text, promptTokens, candidatesTokens);
        }
        catch (Exception ex)
        {
             throw new Exception("Failed to parse Gemini response", ex);
        }
    }

    public async Task<List<VocabularyExtractionDto>> ExtractVocabularyAsync(string text)
    {
        var apiKey = _configuration["Gemini:ApiKey"];
        var model = _configuration["Gemini:Model"] ?? "gemini-2.0-flash-lite";
        var url = $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";
        
        var prompt = @"Analyze the following text. Identify 3 to 5 advanced or useful English vocabulary words or idioms (CEFR B2-C2 level) present in the text. 
Return strictly a JSON array of objects. Do not include markdown formatting like ```json or ```. Just the raw JSON array.
Format: 
[
  { ""word"": ""Word"", ""definition"": ""Brief definition"", ""partOfSpeech"": ""Part of speech"", ""context"": ""Original context from text"" }
]

Text to analyze:
" + text;

        var requestBody = new
        {
            contents = new[]
            {
                new { role = "user", parts = new[] { new { text = prompt } } }
            },
            generationConfig = new
            {
                temperature = 0.3,
                maxOutputTokens = 1024
            }
        };

        var jsonBody = JsonSerializer.Serialize(requestBody);
        var content = new StringContent(jsonBody, Encoding.UTF8, "application/json");

        var client = _httpClientFactory.CreateClient("GeminiClient");
        var response = await client.PostAsync(url, content);

        if (!response.IsSuccessStatusCode)
        {
            var errorBody = await response.Content.ReadAsStringAsync();
            throw new HttpRequestException($"Gemini API Error: {response.StatusCode} - {errorBody}");
        }

        var responseString = await response.Content.ReadAsStringAsync();
        using var document = JsonDocument.Parse(responseString);
        
        try 
        {
            if (!document.RootElement.TryGetProperty("candidates", out var candidates) || candidates.GetArrayLength() == 0)
            {
                // No candidates (blocked?)
                Console.WriteLine("Gemini: No candidates returned (Safety block?)");
                return new List<VocabularyExtractionDto>();
            }

            var firstCand = candidates[0];
            if (!firstCand.TryGetProperty("content", out var contentDoc))
            {
                 Console.WriteLine("Gemini: Candidate has no content (Safety block?)");
                 return new List<VocabularyExtractionDto>();
            }

            var rawText = contentDoc.GetProperty("parts")[0].GetProperty("text").GetString() ?? "[]";

            // Cleanup markdown
            rawText = rawText.Trim();
            if (rawText.StartsWith("```json")) rawText = rawText.Substring(7);
            else if (rawText.StartsWith("```")) rawText = rawText.Substring(3); // Handle generic code block
            
            if (rawText.EndsWith("```")) rawText = rawText.Substring(0, rawText.Length - 3);
            rawText = rawText.Trim();

            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            var result = JsonSerializer.Deserialize<List<VocabularyExtractionDto>>(rawText, options);
            return result ?? new List<VocabularyExtractionDto>();
        }
        catch (Exception ex)
        {
             Console.WriteLine($"Failed to parse vocabulary: {ex.Message}");
             return new List<VocabularyExtractionDto>();
        }
    }
}
