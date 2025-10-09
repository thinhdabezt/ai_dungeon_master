using Microsoft.AspNetCore.Mvc;
using AiDungeonMaster.Api.Models;
using AiDungeonMaster.Api.Services;
using BCrypt.Net;
using Microsoft.Extensions.Configuration;
using System.IdentityModel.Tokens.Jwt;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using System.Security.Claims;

namespace AiDungeonMaster.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IPlayerService _playerService;
        private readonly IConfiguration _config;

        public AuthController(IPlayerService playerService, IConfiguration config)
        {
            _playerService = playerService;
            _config = config;
        }

        [HttpPost("register")]
        public IActionResult Register([FromBody] RegisterRequest req)
        {
            if (string.IsNullOrWhiteSpace(req.Name) || string.IsNullOrWhiteSpace(req.Password))
                return BadRequest("Name and password required.");

            var existing = _playerService.GetPlayerByEmail(req.Email);
            if (existing != null) return Conflict("Email already registered.");

            var hash = BCrypt.Net.BCrypt.HashPassword(req.Password);
            var player = _playerService.CreatePlayer(req.Name, req.Email, hash);
            return Ok(new { player.Id, player.Name, player.Email });
        }

        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginRequest req)
        {
            if (string.IsNullOrWhiteSpace(req.Email) || string.IsNullOrWhiteSpace(req.Password))
                return BadRequest("Email and password required.");

            var player = _playerService.GetPlayerByEmail(req.Email);
            if (player == null) return Unauthorized("Invalid credentials.");

            if (string.IsNullOrEmpty(player.PasswordHash) || !BCrypt.Net.BCrypt.Verify(req.Password, player.PasswordHash))
                return Unauthorized("Invalid credentials.");

            var token = GenerateJwtToken(player);
            return Ok(new { token, player.Id, player.Name });
        }

        private string GenerateJwtToken(Player player)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, player.Id.ToString()),
                new Claim("name", player.Name),
                new Claim(JwtRegisteredClaimNames.Email, player.Email ?? ""),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var expires = DateTime.UtcNow.AddMinutes(double.Parse(_config["Jwt:ExpireMinutes"] ?? "1440"));

            var token = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: expires,
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }

    // DTOs
    public class RegisterRequest
    {
        public string Name { get; set; } = "";
        public string Email { get; set; } = "";
        public string Password { get; set; } = "";
    }

    public class LoginRequest
    {
        public string Email { get; set; } = "";
        public string Password { get; set; } = "";
    }
}
