//using Microsoft.AspNetCore.Mvc;
//using AiDungeonMaster.Api.Models;
//using AiDungeonMaster.Api.Services;

//namespace AiDungeonMaster.Api.Controllers
//{
//    [ApiController]
//    [Route("api/[controller]")]
//    public class PlayerController : ControllerBase
//    {
//        private readonly IPlayerService _playerService;

//        public PlayerController(IPlayerService playerService)
//        {
//            _playerService = playerService;
//        }

//        [HttpPost]
//        public IActionResult CreatePlayer([FromBody] Player player)
//        {
//            if (string.IsNullOrWhiteSpace(player.Name))
//                return BadRequest("Player name is required.");

//            var newPlayer = _playerService.CreatePlayer(player.Name);
//            return Ok(newPlayer);
//        }

//        [HttpGet]
//        public IActionResult GetPlayers()
//        {
//            var players = _playerService.GetAllPlayers();
//            return Ok(players);
//        }

//        [HttpGet("{id}")]
//        public IActionResult GetPlayer(int id)
//        {
//            var player = _playerService.GetPlayerById(id);
//            if (player == null) return NotFound();
//            return Ok(player);
//        }
//    }
//}
