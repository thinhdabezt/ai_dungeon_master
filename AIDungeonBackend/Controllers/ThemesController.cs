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
        var themes = await _context.Themes
            .OrderBy(t => t.Id)
            .ToListAsync();
        return Ok(themes);
    }

    [HttpGet("{key}")]
    public async Task<IActionResult> GetTheme(string key)
    {
        var theme = await _context.Themes.FirstOrDefaultAsync(t => t.Key == key);
        if (theme == null) return NotFound();
        return Ok(theme);
    }
}
