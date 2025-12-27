class VocabularyExtractionDto {
  final String word;
  final String definition;
  final String partOfSpeech;
  final String context;

  VocabularyExtractionDto({
    required this.word,
    required this.definition,
    required this.partOfSpeech,
    required this.context,
  });

  factory VocabularyExtractionDto.fromJson(Map<String, dynamic> json) {
    return VocabularyExtractionDto(
      word: json['word'] ?? '',
      definition: json['definition'] ?? '',
      partOfSpeech: json['partOfSpeech'] ?? '',
      context: json['context'] ?? '',
    );
  }
}
