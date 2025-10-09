using AiDungeonMaster.Api.Data;
using AiDungeonMaster.Api.Models;
using AiDungeonMaster.Api.Services;
using BCrypt.Net;
using Google.Apis.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace AiDungeonMaster.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IPlayerService _playerService;
        private readonly ITokenService _tokenService;
        private readonly AppDbContext _context;
        private readonly IConfiguration _config;

        public AuthController(IPlayerService playerService, ITokenService tokenService, AppDbContext context, IConfiguration config)
        {
            _playerService = playerService;
            _tokenService = tokenService;
            _context = context;
            _config = config;
        }

        [HttpPost("register")]
        public IActionResult Register([FromBody] RegisterRequest req)
        {
            if (string.IsNullOrWhiteSpace(req.Name) || string.IsNullOrWhiteSpace(req.Password) || string.IsNullOrWhiteSpace(req.Email))
                return BadRequest("Name, email and password required.");

            var exists = _playerService.GetPlayerByEmail(req.Email);
            if (exists != null) return Conflict("Email already registered.");

            var hash = BCrypt.Net.BCrypt.HashPassword(req.Password);
            var role = req.Role ?? "User";
            var player = _playerService.CreatePlayer(req.Name, req.Email, hash, role);

            return Ok(new { player.Id, player.Name, player.Email, player.Role });
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

            var accessToken = _tokenService.GenerateAccessToken(player);
            var jwtHandler = new JwtSecurityTokenHandler();
            var jwtToken = jwtHandler.ReadJwtToken(accessToken);
            var jti = jwtToken.Id;

            var (refreshTokenRaw, dbEntry) = _tokenService.GenerateRefreshToken(jti, player.Id, HttpContext.Connection.RemoteIpAddress?.ToString());
            _context.RefreshTokens.Add(dbEntry);
            _context.SaveChanges();

            return Ok(new { token = accessToken, refreshToken = refreshTokenRaw, player.Id, player.Name, player.Role });
        }

        [HttpPost("refresh")]
        public IActionResult Refresh([FromBody] RefreshRequest req)
        {
            if (string.IsNullOrWhiteSpace(req.Token) || string.IsNullOrWhiteSpace(req.RefreshToken))
                return BadRequest("Token and refreshToken required.");

            var principal = GetPrincipalFromExpiredToken(req.Token);
            if (principal == null) return BadRequest("Invalid token.");

            var jti = principal.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Jti)?.Value;
            var userIdClaim = principal.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Sub)?.Value;
            if (userIdClaim == null) return BadRequest("Invalid token payload.");

            var playerId = int.Parse(userIdClaim);

            var dbToken = _context.RefreshTokens.FirstOrDefault(r => r.PlayerId == playerId && r.JwtId == jti && !r.Revoked);
            if (dbToken == null) return Unauthorized("Refresh token not found.");

            if (dbToken.ExpiresAt < DateTime.UtcNow) return Unauthorized("Refresh token expired.");

            if (!BCrypt.Net.BCrypt.Verify(req.RefreshToken, dbToken.TokenHash)) return Unauthorized("Invalid refresh token.");

            // rotate
            dbToken.Revoked = true;
            _context.RefreshTokens.Update(dbToken);

            var player = _playerService.GetPlayerById(playerId);
            if (player == null) return Unauthorized("User not found.");

            var newAccessToken = _tokenService.GenerateAccessToken(player);
            var jwtHandler = new JwtSecurityTokenHandler();
            var jwtToken = jwtHandler.ReadJwtToken(newAccessToken);
            var newJti = jwtToken.Id;

            var (newRefreshRaw, newDbEntry) = _tokenService.GenerateRefreshToken(newJti, player.Id, HttpContext.Connection.RemoteIpAddress?.ToString());
            _context.RefreshTokens.Add(newDbEntry);
            _context.SaveChanges();

            return Ok(new { token = newAccessToken, refreshToken = newRefreshRaw });
        }

        [HttpPost("revoke")]
        [Authorize]
        public IActionResult Revoke([FromBody] RevokeRequest req)
        {
            var userId = int.Parse(User.FindFirstValue(JwtRegisteredClaimNames.Sub));
            var tokens = _context.RefreshTokens
                .Where(t => t.PlayerId == userId && !t.Revoked)
                .ToList();

            RefreshToken tokenToRevoke = null;
            if (req.RefreshToken == null)
            {
                tokenToRevoke = tokens.FirstOrDefault();
            }
            else
            {
                tokenToRevoke = tokens.FirstOrDefault(t => BCrypt.Net.BCrypt.Verify(req.RefreshToken, t.TokenHash));
            }

            if (tokenToRevoke != null)
            {
                tokenToRevoke.Revoked = true;
                _context.SaveChanges();
            }

            return Ok();
        }

        [HttpPost("google")]
        public async Task<IActionResult> GoogleSignIn([FromBody] GoogleSignInRequest req)
        {
            if (string.IsNullOrWhiteSpace(req.IdToken)) return BadRequest("idToken required.");

            GoogleJsonWebSignature.Payload payload;
            try
            {
                var settings = new GoogleJsonWebSignature.ValidationSettings()
                {
                    Audience = new[] { _config["Authentication:Google:ClientId"] ?? _config["Authentication:Google:ClientId"] }
                };
                payload = await GoogleJsonWebSignature.ValidateAsync(req.IdToken, settings);
            }
            catch (Exception ex)
            {
                return BadRequest($"Invalid Google id_token. {ex.Message}");
            }

            var email = payload.Email;
            var name = payload.Name ?? payload.Email?.Split('@')[0] ?? "GoogleUser";

            var player = _playerService.GetPlayerByEmail(email);
            if (player == null)
            {
                player = _playerService.CreatePlayer(name, email, null, "User");
            }

            var accessToken = _tokenService.GenerateAccessToken(player);
            var jwtHandler = new JwtSecurityTokenHandler();
            var jwtToken = jwtHandler.ReadJwtToken(accessToken);
            var jti = jwtToken.Id;

            var (refreshTokenRaw, dbEntry) = _tokenService.GenerateRefreshToken(jti, player.Id, HttpContext.Connection.RemoteIpAddress?.ToString());
            _context.RefreshTokens.Add(dbEntry);
            _context.SaveChanges();

            return Ok(new { token = accessToken, refreshToken = refreshTokenRaw, player.Id, player.Name });
        }

        // Helpers & DTOs
        private ClaimsPrincipal? GetPrincipalFromExpiredToken(string token)
        {
            var tokenValidationParameters = new TokenValidationParameters
            {
                ValidateAudience = true,
                ValidateIssuer = true,
                ValidateIssuerSigningKey = true,
                ValidateLifetime = false, // allow expired
                ValidIssuer = _config["Jwt:Issuer"],
                ValidAudience = _config["Jwt:Audience"],
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]))
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            try
            {
                var principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out var securityToken);
                if (!(securityToken is JwtSecurityToken jwtSecurityToken) ||
                    !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase))
                    return null;

                return principal;
            }
            catch
            {
                return null;
            }
        }
    }

    // DTOs for controller
    public class RegisterRequest { public string Name { get; set; } = ""; public string Email { get; set; } = ""; public string Password { get; set; } = ""; public string? Role { get; set; } }
    public class LoginRequest { public string Email { get; set; } = ""; public string Password { get; set; } = ""; }
    public class RefreshRequest { public string Token { get; set; } = ""; public string RefreshToken { get; set; } = ""; }
    public class RevokeRequest { public string? RefreshToken { get; set; } }
    public class GoogleSignInRequest { public string IdToken { get; set; } = ""; }
}
