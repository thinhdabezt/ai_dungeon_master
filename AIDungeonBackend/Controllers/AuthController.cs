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
    public IActionResult Me()
    {
        var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        var username = User.FindFirst(System.Security.Claims.ClaimTypes.Name)?.Value;
        var email = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value;

        return Ok(new { Id = userId, Username = username, Email = email });
    }
}

public record RegisterDto(string Username, string Email, string Password);
public record LoginDto(string UsernameOrEmail, string Password);
