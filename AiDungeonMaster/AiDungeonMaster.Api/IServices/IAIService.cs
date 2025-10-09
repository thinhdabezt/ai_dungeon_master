using AiDungeonMaster.Api.Models;

namespace AiDungeonMaster.Api.IServices
{
    public interface IAIService
    {
        StoryResponse GenerateStory(StoryRequest request);
    }
}
