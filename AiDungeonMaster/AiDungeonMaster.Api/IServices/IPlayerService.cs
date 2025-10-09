using AiDungeonMaster.Api.Models;

namespace AiDungeonMaster.Api.Services
{
    public interface IPlayerService
    {
        Player CreatePlayer(string name, string? email, string? passwordHash = null);
        Player? GetPlayerById(int id);
        Player? GetPlayerByEmail(string? email);
        IEnumerable<Player> GetAllPlayers();
    }
}
