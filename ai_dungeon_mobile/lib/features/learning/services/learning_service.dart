import '../../../core/network/api_client.dart';
import '../models/vocabulary_extraction_dto.dart';
import '../models/flashcard_model.dart';

class LearningService {
  final ApiClient _apiClient;

  LearningService(this._apiClient);

  Future<List<VocabularyExtractionDto>> extractVocabulary(String text) async {
    try {
      final response = await _apiClient.dio.post(
        '/learning/extract',
        data: {'text': text},
      );
      final List<dynamic> data = response.data;
      return data.map((e) => VocabularyExtractionDto.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FlashcardModel>> getCards() async {
    try {
      final response = await _apiClient.dio.get('/learning/cards');
      final List<dynamic> data = response.data;
      return data.map((e) => FlashcardModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveCard({
    required String word,
    required String definition,
    String? contextSentence,
    String? sourceSessionId,
  }) async {
    try {
      await _apiClient.dio.post(
        '/learning/cards',
        data: {
          'word': word,
          'definition': definition,
          'contextSentence': contextSentence,
          'sourceSessionId': sourceSessionId,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
