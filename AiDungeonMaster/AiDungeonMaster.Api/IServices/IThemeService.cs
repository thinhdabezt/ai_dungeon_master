using AiDungeonMaster.Api.Models;

namespace AiDungeonMaster.Api.IServices
{
    public interface IThemeService
    {
        IEnumerable<Theme> GetAllThemes();
        Theme? GetThemeByKey(string key);
    }
}
