using AiDungeonMaster.Api.Models;

namespace AiDungeonMaster.Api.Services
{
    public interface IPlayerService
    {
        Player CreatePlayer(string name);
        Player? GetPlayerById(int id);
        IEnumerable<Player> GetAllPlayers();
    }
}
