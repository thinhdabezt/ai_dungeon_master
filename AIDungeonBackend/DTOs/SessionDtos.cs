using AIDungeonBackend.Models;

namespace AIDungeonBackend.DTOs;

public record StorySessionDto(
    Guid Id,
    Guid UserId,
    string Title,
    string ThemeKey,
    string ThemeName,
    DateTime CreatedAt,
    DateTime LastUpdated,

    List<SessionMessageDto> Messages,
    int DailyTokensUsed,
    int MaxTokens
);

public record SessionMessageDto(
    Guid Id,
    string Role,
    string Content,

    DateTime CreatedAt,
    string? Hint,
    int TokenCount
);

public record RenameSessionDto(string NewTitle);
public record CreateSessionDto(string Title, string ThemeKey, string IeltsBand = "9.0");
public record MessageDto(string Content);
public record ChatRequestDto(string Input, bool IncludeHint = false);
