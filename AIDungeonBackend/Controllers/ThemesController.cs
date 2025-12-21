using AIDungeonBackend.Data;
using AIDungeonBackend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AIDungeonBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ThemesController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public ThemesController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetThemes()
    {
        return Ok(await _context.Themes.ToListAsync());
    }

    [HttpPost("seed")]
    public async Task<IActionResult> Seed()
    {
        if (await _context.Themes.AnyAsync())
        {
            return Ok("Themes already seeded.");
        }

        var defaultTheme = new Theme
        {
            Key = "classic_high_fantasy",
            Name = "Classic High Fantasy",
            PersonaPrompt = "You are an epic High Fantasy Dungeon Master.",
            Temperature = 0.8f,
            MaxTokens = 2048
        };

        _context.Themes.Add(defaultTheme);
        await _context.SaveChangesAsync();

        return Ok("Seeded default theme.");
    }
}
