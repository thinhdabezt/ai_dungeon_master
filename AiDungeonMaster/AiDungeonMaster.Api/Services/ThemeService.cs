using AiDungeonMaster.Api.IServices;
using AiDungeonMaster.Api.Models;

namespace AiDungeonMaster.Api.Services
{
    public class ThemeService : IThemeService
    {
        private readonly List<Theme> _themes = new()
        {
            new Theme
{
    Key = "fantasy",
    Name = "Fantasy Realm",
    Description = "Dragons, knights, magic, and dark dungeons.",
    BasePrompt = "A medieval world filled with dragons, magic, and kingdoms in peril.",
    Persona = "A wise and dramatic Dungeon Master, speaking in archaic tone, weaving grand adventures and ancient prophecies."
},
new Theme
{
    Key = "cyberpunk",
    Name = "Cyberpunk City",
    Description = "Neon lights, hackers, and corrupt megacorporations.",
    BasePrompt = "A futuristic cyberpunk city where hackers rule the underworld and AI controls the skyline.",
    Persona = "A cynical AI narrator with neon-lit sarcasm, describing gritty city life in sharp, edgy sentences."
},
new Theme
{
    Key = "sci-fi",
    Name = "Galactic Odyssey",
    Description = "Spaceships, alien civilizations, and interstellar adventure.",
    BasePrompt = "A vast sci-fi universe full of space stations, alien empires, and cosmic mysteries.",
    Persona = "A calm, analytical storyteller — like a ship AI guiding the player through the cosmos with precision and awe."
},
new Theme
{
    Key = "horror",
    Name = "Haunted Shadows",
    Description = "Abandoned mansions, curses, and ancient evils lurking in the dark.",
    BasePrompt = "A horror world where whispers haunt every corridor and shadows hide ancient curses.",
    Persona = "A whispering, unsettling narrator who speaks as if they are watching the player from the dark."
},
new Theme
{
    Key = "mythology",
    Name = "Mythic Legends",
    Description = "Greek gods, Norse giants, and epic divine conflicts.",
    BasePrompt = "An ancient world where gods and mortals clash in mythic tales.",
    Persona = "A divine herald or oracle, speaking with grandeur and reverence as if channeling the will of the gods."
},
new Theme
{
    Key = "post_apocalypse",
    Name = "Wasteland Survival",
    Description = "Ruined cities, mutant creatures, and desperate survivors fighting for resources.",
    BasePrompt = "A post-apocalyptic wasteland where civilization has collapsed and survival is the only rule.",
    Persona = "A grizzled survivor with a rough voice, speaking like a wasteland radio DJ warning you of danger."
},
new Theme
{
    Key = "steampunk",
    Name = "Clockwork Empire",
    Description = "Steam-powered machines, skyships, and Victorian intrigue.",
    BasePrompt = "An alternate steampunk world powered by gears, steam, and ambition in a grand empire of invention.",
    Persona = "An eloquent inventor with flair and wit, describing events like a theatrical engineer narrating a spectacle."
},
new Theme
{
    Key = "lovecraftian",
    Name = "Eldritch Abyss",
    Description = "Forbidden tomes, cosmic horrors, and sanity slipping into madness.",
    BasePrompt = "A dark Lovecraftian world where ancient beings whisper from the void and knowledge comes at a terrible cost.",
    Persona = "An ominous cosmic scholar whose every word feels heavy with forbidden knowledge and creeping madness."
},
new Theme
{
    Key = "samurai",
    Name = "Shadows of Edo",
    Description = "Ronin, shoguns, and the code of bushido in feudal Japan.",
    BasePrompt = "A world inspired by feudal Japan where honor, vengeance, and ancient spirits shape every sword clash.",
    Persona = "A stoic sensei who speaks in poetic metaphors about honor, duty, and death — calm yet powerful."
}

        };

        public IEnumerable<Theme> GetAllThemes() => _themes;
        public Theme? GetThemeByKey(string key) =>
            _themes.FirstOrDefault(t => t.Key.Equals(key, StringComparison.OrdinalIgnoreCase));
    }
}
