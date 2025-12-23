using AIDungeonBackend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AIDungeonBackend.Controllers;

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

    [HttpPost]
    public async Task<IActionResult> CreateSession([FromBody] CreateSessionDto dto)
    {
        try 
        {
            var session = await _sessionService.CreateSessionAsync(GetUserId(), dto.Title, dto.ThemeKey);
            return Ok(session);
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
        return Ok(sessions);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetSession(Guid id)
    {
        var session = await _sessionService.GetSessionAsync(id, GetUserId());
        if (session == null) return NotFound();
        return Ok(session);
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
            return StatusCode(503, ex.Message); // Service Unavailable for AI errors
        }
    }
}

public record CreateSessionDto(string Title, string ThemeKey);
public record MessageDto(string Content);
public record ChatRequestDto(string Input, bool IncludeHint = false);
