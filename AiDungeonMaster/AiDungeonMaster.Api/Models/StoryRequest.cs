namespace AiDungeonMaster.Api.Models
{
    public class StoryRequest
    {
        public string? SessionId { get; set; }
        public int? PlayerId { get; set; }
        public string? PlayerName { get; set; }
        public string? Prompt { get; set; }
        public string? ThemeKey { get; set; }
    }
}
