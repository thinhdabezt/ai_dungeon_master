using AiDungeonMaster.Api.Models;

namespace AiDungeonMaster.Api.Services
{
    public interface ITokenService
    {
        string GenerateAccessToken(Player player);
        (string refreshToken, RefreshToken dbEntry) GenerateRefreshToken(string jwtId, int playerId, string remoteIp = null);
    }
}
