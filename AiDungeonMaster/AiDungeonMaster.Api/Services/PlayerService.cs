using AiDungeonMaster.Api.Data;
using AiDungeonMaster.Api.Models;

namespace AiDungeonMaster.Api.Services
{
    public class PlayerService : IPlayerService
    {
        private readonly AppDbContext _context;

        public PlayerService(AppDbContext context)
        {
            _context = context;
        }

        public Player CreatePlayer(string name)
        {
            var player = new Player { Name = name};
            _context.Players.Add(player);
            _context.SaveChanges();
            return player;
        }

        public Player? GetPlayerById(int id)
        {
            return _context.Players.FirstOrDefault(p => p.Id == id);
        }

        public IEnumerable<Player> GetAllPlayers() => _context.Players.ToList();
    }
}
