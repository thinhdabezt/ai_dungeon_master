using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
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

    public async Task<string> GenerateContentAsync(string systemPrompt, List<SessionMessage> history, string newUserInput)
    {
        var apiKey = _configuration["Gemini:ApiKey"];
        var model = _configuration["Gemini:Model"] ?? "gemini-1.5-flash";
        var url = $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";

        // Build prompt structure
        // Gemini API expects "contents" array with "role" (user/model) and "parts"
        
        var contents = new List<object>();

        // System prompt isn't strictly "system" role in all Gemini versions, 
        // but typically handled as initial context or specialized system instruction if supported.
        // For simple flash/pro chat-v1, we can prepend it or use "system" role if the model supports it (1.5-flash does).
        
        // Let's use the explicit "systemInstruction" property if utilizing v1beta API properly, 
        // OR just prepend to the prompt context. To be safe and simple with REST:
        // We will pass system instruction as a separate parameter if the API supports it, 
        // but standard practice for REST: simple contents array.
        
        // HOWEVER, v1beta models/gemini-1.5-flash supports "systemInstruction" field at the top level.
        
        foreach (var msg in history)
        {
            var role = msg.Role == "player" ? "user" : "model";
            contents.Add(new
            {
                role = role,
                parts = new[] { new { text = msg.Content } }
            });
        }

        // Add the new user input
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
                temperature = 0.7, // could be parameterized from Theme
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
                .GetString();
                
            return text ?? "";
        }
        catch (Exception ex)
        {
             throw new Exception("Failed to parse Gemini response", ex);
        }
    }
}
