namespace AIDungeonBackend.DTOs;

public record VocabularyExtractionDto(string Word, string Definition, string PartOfSpeech, string Context);

public record CreateFlashcardDto(string Word, string Definition, string? ContextSentence, Guid? SourceSessionId);

public record FlashcardDto(Guid Id, string Word, string Definition, string? ContextSentence, DateTime CreatedAt);
