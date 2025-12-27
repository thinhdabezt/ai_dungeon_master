class FlashcardModel {
  final String id;
  final String word;
  final String definition;
  final String? contextSentence;
  final DateTime createdAt;

  FlashcardModel({
    required this.id,
    required this.word,
    required this.definition,
    this.contextSentence,
    required this.createdAt,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] as String,
      word: json['word'] as String,
      definition: json['definition'] as String,
      contextSentence: json['contextSentence'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
