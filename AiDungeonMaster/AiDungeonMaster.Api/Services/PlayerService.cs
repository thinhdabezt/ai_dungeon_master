using AiDungeonMaster.Api.Data;
using AiDungeonMaster.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace AiDungeonMaster.Api.Services
{
    public class PlayerService : IPlayerService
    {
        private readonly AppDbContext _context;
        public PlayerService(AppDbContext context) => _context = context;

        public Player CreatePlayer(string name, string? email, string? passwordHash = null, string? role = "User")
        {
            var player = new Player { Name = name, Email = email, PasswordHash = passwordHash, Role = role ?? "User" };
            _context.Players.Add(player);
            _context.SaveChanges();
            return player;
        }

        public Player? GetPlayerById(int id)
        {
            return _context.Players.Include(p => p.Sessions).FirstOrDefault(p => p.Id == id);
        }

        public Player? GetPlayerByEmail(string? email)
        {
            if (string.IsNullOrWhiteSpace(email)) return null;
            return _context.Players.FirstOrDefault(p => p.Email == email);
        }

        public IEnumerable<Player> GetAllPlayers() => _context.Players.ToList();
    }
}
