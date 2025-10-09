using AiDungeonMaster.Api.IServices;
using AiDungeonMaster.Api.Models;
using Microsoft.Extensions.Configuration;
using System.Diagnostics.Metrics;
using System.Net.Http.Json;
using System.Text.Json;

namespace AiDungeonMaster.Api.Services
{
    public class GeminiAIService : IAIService
    {
        private readonly IConfiguration _config;
        private readonly HttpClient _httpClient;
        private readonly string _apiKey;
        private readonly ISessionService _sessionService;
        private readonly IThemeService _themeService;

        public GeminiAIService(IConfiguration config, IHttpClientFactory httpClientFactory, ISessionService sessionService, IThemeService themeService)
        {
            _config = config;
            _httpClient = httpClientFactory.CreateClient();
            _apiKey = _config["GoogleAI:ApiKey"] ?? throw new Exception("Missing GoogleAI:ApiKey in appsettings.json");
            _sessionService = sessionService;
            _themeService = themeService;
        }

        public StoryResponse GenerateStory(StoryRequest request)
        {
            var session = _sessionService.GetOrCreateSession(request.SessionId, request.ThemeKey);

            var player = string.IsNullOrWhiteSpace(request.PlayerName) ? "Adventurer" : request.PlayerName;
            var input = request.Prompt ?? "continues their journey.";

            // Lấy thông tin theme (để thêm persona)
            Theme? theme = null;
            if (!string.IsNullOrWhiteSpace(request.ThemeKey))
                theme = _themeService.GetThemeByKey(request.ThemeKey);

            // Tạo context hội thoại
            var history = string.Join("\n", _sessionService.GetFullContext(session.SessionId));

            // Tạo prompt có persona và basePrompt
            var personaIntro = theme?.Persona ?? "A neutral Dungeon Master narrates the story.";
            var baseSetting = theme?.BasePrompt ?? "An undefined world where adventure unfolds.";
            var safeHistory = string.IsNullOrWhiteSpace(history) ? "No previous conversation." : history;
            var safePlayer = string.IsNullOrWhiteSpace(player) ? "Unknown Player" : player;
            var safeInput = string.IsNullOrWhiteSpace(input) ? "" : input;

            var finalPrompt = $@"
            {personaIntro}
            
            Setting:
            {baseSetting}
            
            Previous conversation:
            {safeHistory}
            
            New action:
            Player: {safePlayer} says ""{safeInput}""
            
            Respond as Dungeon Master in the same persona and tone. Continue the story vividly but briefly, keep your response 6-7 setences and always create a situation where player have to act.
            ";

            // Gửi request đến Gemini
            var payload = new
            {
                contents = new[]
                {
            new
            {
                parts = new[]
                {
                    new { text = finalPrompt }
                }
            }
        }
            };

            var url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={_apiKey}";
            var response = _httpClient.PostAsJsonAsync(url, payload).Result;

            if (!response.IsSuccessStatusCode)
            {
                var err = response.Content.ReadAsStringAsync().Result;
                return new StoryResponse { Response = $"Error: {err}" };
            }

            var json = response.Content.ReadAsStringAsync().Result;
            using var doc = JsonDocument.Parse(json);
            var text = doc.RootElement
                .GetProperty("candidates")[0]
                .GetProperty("content")
                .GetProperty("parts")[0]
                .GetProperty("text")
                .GetString() ?? "(No response from AI)";

            // Save to session history
            _sessionService.AddExchange(session.SessionId, input, text);

            return new StoryResponse
            {
                Response = text,
                SessionId = session.SessionId
            };
        }
    }
}
