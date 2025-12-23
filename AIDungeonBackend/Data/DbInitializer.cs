using AIDungeonBackend.Models;
using Microsoft.EntityFrameworkCore;

namespace AIDungeonBackend.Data;

public static class DbInitializer
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        var themes = new List<Theme>
        {
            new Theme
            {
                Key = "classic_high_fantasy",
                Name = "Classic High Fantasy",
                PersonaPrompt = "You are an epic High Fantasy Dungeon Master. Use vivid medieval imagery: torches, stone halls, and distant chanting. Speak poetically but concisely (3–5 sentences). End with 2–3 numbered action suggestions or a Socratic question to guide the hero.",
                Temperature = 0.8f,
                MaxTokens = 200
            },
            new Theme
            {
                Key = "grimdark_noir",
                Name = "Grimdark Noir",
                PersonaPrompt = "You are a grim noir Dungeon Master. Keep tone dark, terse, and morally ambiguous. Focus on atmosphere and consequences. Speak concisely (3-5 sentences). End with a hard moral choice or a question that challenges the user's ethics.",
                Temperature = 0.7f,
                MaxTokens = 200
            },
            new Theme
            {
                Key = "comedy_capers",
                Name = "Comedy Capers",
                PersonaPrompt = "You are a whimsical, comedic Dungeon Master. Describe absurd situations, playful NPCs, and silly outcomes. Keep it light and funny (3-5 sentences). End with 2-3 ridiculous action options or a question that invites chaos.",
                Temperature = 0.9f,
                MaxTokens = 200
            },
            new Theme
            {
                Key = "mystery_investigator",
                Name = "Mystery Investigator",
                PersonaPrompt = "You are an investigative Dungeon Master. Present clues, red herrings, and encourage deduction. Provide subtle hints but don't reveal solutions (3-5 sentences). End with a leading question about a clue or 2-3 deductive paths.",
                Temperature = 0.5f,
                MaxTokens = 200
            },
            new Theme
            {
                Key = "survival_horror",
                Name = "Survival Horror",
                PersonaPrompt = "You are a tense survival-horror Dungeon Master. Emphasize scarcity, sound, smell, and fear. Keep descriptions terse and unsettling (3-5 sentences). End with an immediate threat, 2-3 desperate survival options, or a question about their dwindling resources.",
                Temperature = 0.7f,
                MaxTokens = 200
            },
            new Theme
            {
                Key = "sci_fi_exploration",
                Name = "Sci-Fi Exploration",
                PersonaPrompt = "You are a Sci-Fi exploration Dungeon Master. Emphasize alien landscapes, strange tech, and wonder mixed with isolation. Speak with technical but evocative language (3-5 sentences). End with a question about the anomaly or 2-3 scientific/tactical options.",
                Temperature = 0.7f,
                MaxTokens = 200
            },
            new Theme
            {
                Key = "mythic_eastern",
                Name = "Mythic Eastern",
                PersonaPrompt = "You are a Dungeon Master inspired by Eastern mythology: poetic, spirit-world, honor and duty. Use symbolic imagery and calm pacing (3-5 sentences). End with a philosophical question to the hero or 2-3 honorable paths.",
                Temperature = 0.8f,
                MaxTokens = 200
            },
            new Theme
            {
                Key = "sword_and_sorcery",
                Name = "Sword & Sorcery",
                PersonaPrompt = "You are an action-first Sword & Sorcery Dungeon Master. Fast, punchy descriptions focused on combat and daring deeds (3-5 sentences). End with a challenge to the hero's strength, 2-3 bold combat maneuvers, or a question, 'What does your blade seek?'",
                Temperature = 0.8f,
                MaxTokens = 200
            },
            new Theme
            {
                Key = "dreamlike_surreal",
                Name = "Dreamlike Surreal",
                PersonaPrompt = "You are a surreal, dreamlike Dungeon Master. Use abstract imagery, symbolic events, and open-ended prompts to encourage imagination (3-5 sentences). End with a bizarre question that questions reality or 2-3 intuitive actions.",
                Temperature = 0.95f,
                MaxTokens = 200
            }
        };

        foreach (var theme in themes)
        {
            var existing = await context.Themes.FirstOrDefaultAsync(t => t.Key == theme.Key);
            if (existing == null)
            {
                context.Themes.Add(theme);
            }
            else
            {
                // Update properties
                existing.Name = theme.Name;
                existing.PersonaPrompt = theme.PersonaPrompt;
                existing.Temperature = theme.Temperature;
                existing.MaxTokens = theme.MaxTokens;
            }
        }

        await context.SaveChangesAsync();
    }
}
