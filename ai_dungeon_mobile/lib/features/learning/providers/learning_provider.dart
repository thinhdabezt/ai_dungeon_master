import 'package:flutter/material.dart';
import '../services/learning_service.dart';
import '../models/flashcard_model.dart';
import '../models/vocabulary_extraction_dto.dart';

class LearningProvider extends ChangeNotifier {
  final LearningService _service;
  
  List<FlashcardModel> _cards = [];
  bool _isLoading = false;
  String? _errorMessage;

  LearningProvider(this._service);

  List<FlashcardModel> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();
    try {
      _cards = await _service.getCards();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load cards: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<VocabularyExtractionDto>> extractVocabulary(String text) {
    return _service.extractVocabulary(text);
  }

  Future<void> saveCard(String word, String definition, String context, String? sessionId) async {
    try {
      await _service.saveCard(word: word, definition: definition, contextSentence: context, sourceSessionId: sessionId);
      await loadCards(); // Refresh list
    } catch (e) {
      _errorMessage = 'Failed to save card: $e';
      notifyListeners();
      throw e;
    }
  }
  Future<void> deleteCard(String id) async {
    try {
      await _service.deleteCard(id);
      _cards.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete card: $e';
      notifyListeners();
      throw e;
    }
  }
}
