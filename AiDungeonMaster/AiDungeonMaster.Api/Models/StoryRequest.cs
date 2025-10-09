namespace AiDungeonMaster.Api.Models
{
    public class StoryRequest
    {
        public string? PlayerName { get; set; }
        public string? Prompt { get; set; }
        public string? ThemeKey { get; set; }
        public string? SessionId { get; set; }
    }
}
