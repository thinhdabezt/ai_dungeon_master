using System.Security.Cryptography;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using AiDungeonMaster.Api.Models;
using Microsoft.Extensions.Configuration;

namespace AiDungeonMaster.Api.Services
{
    public class TokenService : ITokenService
    {
        private readonly IConfiguration _config;
        public TokenService(IConfiguration config) => _config = config;

        public string GenerateAccessToken(Player player)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, player.Id.ToString()),
                new Claim("name", player.Name),
                new Claim(JwtRegisteredClaimNames.Email, player.Email ?? ""),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.Role, player.Role ?? "User")
            };

            var expires = DateTime.UtcNow.AddMinutes(double.Parse(_config["Jwt:AccessExpireMinutes"] ?? "60"));

            var token = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: expires,
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        public (string refreshToken, RefreshToken dbEntry) GenerateRefreshToken(string jwtId, int playerId, string remoteIp = null)
        {
            var randomBytes = new byte[64];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomBytes);
            var refreshTokenRaw = Convert.ToBase64String(randomBytes);

            var hash = BCrypt.Net.BCrypt.HashPassword(refreshTokenRaw);

            var expires = DateTime.UtcNow.AddDays(double.Parse(_config["Jwt:RefreshExpireDays"] ?? "30"));

            var dbEntry = new RefreshToken
            {
                JwtId = jwtId,
                PlayerId = playerId,
                TokenHash = hash,
                CreatedAt = DateTime.UtcNow,
                ExpiresAt = expires,
                Revoked = false,
                RemoteIpAddress = remoteIp
            };

            return (refreshTokenRaw, dbEntry);
        }
    }
}
