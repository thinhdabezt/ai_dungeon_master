using AIDungeonBackend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AIDungeonBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDto dto)
    {
        var user = await _authService.RegisterAsync(dto.Username, dto.Email, dto.Password);
        if (user == null)
        {
            return BadRequest("Username or Email already exists.");
        }
        return Ok(new { Message = "User registered successfully", UserId = user.Id });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var (accessToken, refreshToken) = await _authService.LoginAsync(dto.UsernameOrEmail, dto.Password);
        if (accessToken == null)
        {
            return Unauthorized("Invalid credentials.");
        }
        return Ok(new { AccessToken = accessToken, RefreshToken = refreshToken });
    }

    [Authorize]
    [HttpGet("me")]
    public async Task<IActionResult> Me()
    {
        var userIdString = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userIdString, out var userId)) return Unauthorized();

        var user = await _authService.GetUserByIdAsync(userId);
        if (user == null) return NotFound("User not found.");

        return Ok(new UserResponseDto(
            user.Id,
            user.Username,
            user.Email,
            user.LearningXP,
            user.CurrentStreak,
            user.LastStudyDate,
            user.AvatarUrl
        ));
    }

    [Authorize]
    [HttpPatch("settings")]
    public async Task<IActionResult> UpdateSettings([FromBody] UserSettingsDto dto)
    {
        var userIdString = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userIdString, out var userId)) return Unauthorized();

        var success = await _authService.UpdateSettingsAsync(userId, dto.HintEnabled);
        if (!success) return NotFound("User not found.");

        return Ok(new { Message = "Settings updated successfully." });
    }

    [Authorize]
    [HttpPatch("avatar")]
    public async Task<IActionResult> UpdateAvatar([FromBody] UpdateAvatarDto dto)
    {
        var userIdString = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userIdString, out var userId)) return Unauthorized();

        var success = await _authService.UpdateAvatarAsync(userId, dto.AvatarUrl);
        if (!success) return NotFound("User not found.");

        return Ok(new { Message = "Avatar updated successfully.", AvatarUrl = dto.AvatarUrl });
    }
}

public record RegisterDto(string Username, string Email, string Password);
public record LoginDto(string UsernameOrEmail, string Password);
public record UserSettingsDto(bool HintEnabled);
public record UpdateAvatarDto(string AvatarUrl);
public record UserResponseDto(Guid Id, string Username, string Email, int LearningXP, int CurrentStreak, DateTime? LastStudyDate, string? AvatarUrl);
