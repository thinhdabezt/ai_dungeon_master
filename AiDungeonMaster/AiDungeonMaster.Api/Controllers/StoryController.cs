using Microsoft.AspNetCore.Mvc;
using AiDungeonMaster.Api.Models;
using AiDungeonMaster.Api.IServices;

namespace AiDungeonMaster.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class StoryController : ControllerBase
    {
        private readonly IAIService _aiService;
        private readonly IThemeService _themeService;

        public StoryController(IAIService aiService, IThemeService themeService)
        {
            _aiService = aiService;
            _themeService = themeService;
        }

        [HttpPost]
        public IActionResult GenerateStory([FromBody] StoryRequest request)
        {
            if (request == null)
                return BadRequest("Invalid request data.");

            if (!string.IsNullOrWhiteSpace(request.ThemeKey))
            {
                var theme = _themeService.GetThemeByKey(request.ThemeKey);
                if (theme != null && string.IsNullOrWhiteSpace(request.Prompt))
                {
                    request.Prompt = theme.BasePrompt;
                }
            }

            var response = _aiService.GenerateStory(request);
            return Ok(response);
        }
    }
}
