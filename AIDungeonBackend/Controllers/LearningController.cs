using AIDungeonBackend.Data;
using AIDungeonBackend.DTOs;
using AIDungeonBackend.Models;
using AIDungeonBackend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace AIDungeonBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class LearningController : ControllerBase
{
    private readonly IGeminiService _geminiService;
    private readonly ApplicationDbContext _context;

    public LearningController(IGeminiService geminiService, ApplicationDbContext context)
    {
        _geminiService = geminiService;
        _context = context;
    }

    [HttpPost("extract")]
    public async Task<IActionResult> Extract([FromBody] ExtractRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Text)) return BadRequest("Text is required");
        try 
        {
            var result = await _geminiService.ExtractVocabularyAsync(request.Text);
            return Ok(result);
        }
        catch (HttpRequestException ex)
        {
            // Log this properly in production
            Console.WriteLine($"Gemini API Error: {ex.Message}");
            return StatusCode(503, "AI Service unavailable.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Extraction Error: {ex.Message}");
            return StatusCode(500, "Failed to analyze text.");
        }
    }

    [HttpGet("cards")]
    public async Task<IActionResult> GetCards()
    {
        var userId = GetUserId();
        var cards = await _context.Flashcards
            .Where(f => f.UserId == userId)
            .OrderByDescending(f => f.CreatedAt)
            .Select(f => new FlashcardDto(f.Id, f.Word, f.Definition, f.ContextSentence, f.CreatedAt))
            .ToListAsync();
        return Ok(cards);
    }

    [HttpPost("cards")]
    public async Task<IActionResult> CreateCard([FromBody] CreateFlashcardDto dto)
    {
        var userId = GetUserId();
        
        var exists = await _context.Flashcards.AnyAsync(f => f.UserId == userId && f.Word.ToLower() == dto.Word.ToLower());
        if (exists) return Conflict("Word already in grimoire.");
        
        var card = new Flashcard
        {
            UserId = userId,
            Word = dto.Word,
            Definition = dto.Definition,
            ContextSentence = dto.ContextSentence,
            SourceSessionId = dto.SourceSessionId
        };

        _context.Flashcards.Add(card);
        await _context.SaveChangesAsync();
        
        return CreatedAtAction(nameof(GetCards), new { id = card.Id }, new FlashcardDto(card.Id, card.Word, card.Definition, card.ContextSentence, card.CreatedAt));
    }

    [HttpDelete("cards/{id}")]
    public async Task<IActionResult> DeleteCard(Guid id)
    {
        var userId = GetUserId();
        var card = await _context.Flashcards.FirstOrDefaultAsync(f => f.Id == id && f.UserId == userId);
        
        if (card == null) return NotFound();

        _context.Flashcards.Remove(card);
        await _context.SaveChangesAsync();
        
        return NoContent();
    }
    
    private Guid GetUserId()
    {
         return Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? Guid.Empty.ToString());
    }
}

public record ExtractRequest(string Text);
