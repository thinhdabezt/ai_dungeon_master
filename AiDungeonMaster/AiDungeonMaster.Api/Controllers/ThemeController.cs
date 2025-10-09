using Microsoft.AspNetCore.Mvc;
using AiDungeonMaster.Api.IServices;

namespace AiDungeonMaster.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ThemeController : ControllerBase
    {
        private readonly IThemeService _themeService;

        public ThemeController(IThemeService themeService)
        {
            _themeService = themeService;
        }

        [HttpGet]
        public IActionResult GetThemes()
        {
            var themes = _themeService.GetAllThemes();
            return Ok(themes);
        }
    }
}
