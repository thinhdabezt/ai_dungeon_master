using AIDungeonBackend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AIDungeonBackend.Controllers;

using AIDungeonBackend.DTOs;
using AIDungeonBackend.Models;


[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SessionsController : ControllerBase
{
    private readonly ISessionService _sessionService;

    public SessionsController(ISessionService sessionService)
    {
        _sessionService = sessionService;
    }

    private Guid GetUserId()
    {
        var rawId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (Guid.TryParse(rawId, out var userId)) return userId;
        throw new UnauthorizedAccessException("User ID not found in token");
    }

    private static StorySessionDto ToDto(StorySession s)
    {
        return new StorySessionDto(
            s.Id,
            s.UserId,
            s.Title,
            s.Theme?.Key ?? "classic_high_fantasy", // Fallback or strict?
            s.Theme?.Name ?? "Unknown Theme",
            s.CreatedAt,
            s.LastUpdated,
            s.Messages.Select(m => new SessionMessageDto(m.Id, m.Role, m.Content, m.CreatedAt, m.Hint, m.TokenCount ?? 0)).ToList(), // Messages
            s.User?.DailyTokenUsage ?? 0,
            10000 // User Daily Token Limit
        );
    }

    [HttpPost]
    public async Task<IActionResult> CreateSession([FromBody] CreateSessionDto dto)
    {
        try 
        {
            var session = await _sessionService.CreateSessionAsync(GetUserId(), dto.Title, dto.ThemeKey, dto.IeltsBand);
            return Ok(ToDto(session));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpGet]
    public async Task<IActionResult> GetSessions([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var sessions = await _sessionService.GetSessionsAsync(GetUserId(), page, pageSize);
        return Ok(sessions.Select(ToDto));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetSession(Guid id)
    {
        var session = await _sessionService.GetSessionAsync(id, GetUserId());
        if (session == null) return NotFound();
        return Ok(ToDto(session));
    }

    [HttpPost("{id}/messages")]
    public async Task<IActionResult> AddMessage(Guid id, [FromBody] MessageDto dto)
    {
        try
        {
            var message = await _sessionService.AddUserMessageAsync(id, GetUserId(), dto.Content);
            return Ok(message);
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteSession(Guid id)
    {
        await _sessionService.DeleteSessionAsync(id, GetUserId());
        return NoContent();
    }

    [HttpPost("{id}/chat")]
    public async Task<IActionResult> Chat(Guid id, [FromBody] ChatRequestDto dto)
    {
        try
        {
            var message = await _sessionService.ProcessChatAsync(id, GetUserId(), dto.Input, dto.IncludeHint);
            return Ok(message);
        }
        catch (KeyNotFoundException)
        {
            return NotFound("Session not found.");
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
        catch (HttpRequestException ex)
        {
            return StatusCode(503, ex.Message);
        }
    }
    [HttpPatch("{id}/title")]
    public async Task<IActionResult> RenameSession(Guid id, [FromBody] RenameSessionDto dto)
    {
        try
        {
            await _sessionService.RenameSessionAsync(id, GetUserId(), dto.NewTitle);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }
}
