namespace AiDungeonMaster.Api.Models
{
    public class Theme
    {
        public string Key { get; set; } = "";
        public string Name { get; set; } = "";
        public string Description { get; set; } = "";
        public string BasePrompt { get; set; } = "";

        //Persona tone & roleplay guide
        public string Persona { get; set; } = "";
    }
}
