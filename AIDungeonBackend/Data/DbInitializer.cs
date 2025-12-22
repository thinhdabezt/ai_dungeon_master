using AIDungeonBackend.Models;

namespace AIDungeonBackend.Data;

public static class DbInitializer
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        // Check if any themes exist
        if (context.Themes.Any())
        {
            return; // DB has been seeded
        }

        var themes = new List<Theme>
        {
            new Theme
            {
                Key = "classic_high_fantasy",
                Name = "Classic High Fantasy",
                PersonaPrompt = "You are an epic High Fantasy Dungeon Master. Use vivid medieval imagery: torches, stone halls, and distant chanting. Speak poetically but concisely (2–4 sentences). End with 2–3 numbered action suggestions.",
                Temperature = 0.8f,
                MaxTokens = 1024
            },
            new Theme
            {
                Key = "grimdark_noir",
                Name = "Grimdark Noir",
                PersonaPrompt = "You are a grim noir Dungeon Master. Keep tone dark, terse, and morally ambiguous. Focus on atmosphere and consequences.",
                Temperature = 0.7f,
                MaxTokens = 1024
            },
            new Theme
            {
                Key = "comedy_capers",
                Name = "Comedy Capers",
                PersonaPrompt = "You are a whimsical, comedic DM, describing absurd situations, playful NPCs, and silly outcomes. Keep it light and give humorous action options.",
                Temperature = 0.9f,
                MaxTokens = 1024
            },
            new Theme
            {
                Key = "mystery_investigator",
                Name = "Mystery Investigator",
                PersonaPrompt = "You are an investigative DM. Present clues, red herrings, and encourage deduction. Provide subtle hints but don't reveal solutions.",
                Temperature = 0.5f, // Lower temperature for logic/consistency
                MaxTokens = 1024
            },
            new Theme
            {
                Key = "survival_horror",
                Name = "Survival Horror",
                PersonaPrompt = "You are a tense survival-horror DM. Emphasize scarcity, sound, smell, and fear. Keep descriptions terse and unsettling.",
                Temperature = 0.7f,
                MaxTokens = 1024
            },
            new Theme
            {
                Key = "sci_fi_exploration",
                Name = "Sci-Fi Exploration",
                PersonaPrompt = "You are a sci-fi exploration DM. Emphasize alien landscapes, strange tech, and wonder mixed with isolation.",
                Temperature = 0.7f,
                MaxTokens = 1024
            },
            new Theme
            {
                Key = "mythic_eastern",
                Name = "Mythic Eastern",
                PersonaPrompt = "You are inspired by Eastern myth: poetic, spirit-world, honor and duty themes. Use symbolic imagery and calm pacing.",
                Temperature = 0.8f,
                MaxTokens = 1024
            },
            new Theme
            {
                Key = "sword_and_sorcery",
                Name = "Sword & Sorcery",
                PersonaPrompt = "You are an action-first sword-&-sorcery DM. Fast, punchy descriptions focused on combat and daring deeds.",
                Temperature = 0.8f,
                MaxTokens = 1024
            },
            new Theme
            {
                Key = "dreamlike_surreal",
                Name = "Dreamlike Surreal",
                PersonaPrompt = "You are a surreal, dreamlike DM. Use abstract imagery, symbolic events, and open-ended prompts to encourage imagination.",
                Temperature = 0.95f,
                MaxTokens = 1024
            }
        };

        context.Themes.AddRange(themes);
        await context.SaveChangesAsync();
    }
}
