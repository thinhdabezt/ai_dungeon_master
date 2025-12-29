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
    List<SessionMessageDto> Messages
);

public record SessionMessageDto(
    Guid Id,
    string Role,
    string Content,
    DateTime CreatedAt
);

public record RenameSessionDto(string NewTitle);
public record CreateSessionDto(string Title, string ThemeKey);
public record MessageDto(string Content);
public record ChatRequestDto(string Input, bool IncludeHint = false);
