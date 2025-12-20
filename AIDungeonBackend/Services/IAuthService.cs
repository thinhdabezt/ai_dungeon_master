using AIDungeonBackend.Models;

namespace AIDungeonBackend.Services;

public interface IAuthService
{
    Task<User?> RegisterAsync(string username, string email, string password);
    Task<(string? AccessToken, string? RefreshToken)> LoginAsync(string usernameOrEmail, string password);
}
