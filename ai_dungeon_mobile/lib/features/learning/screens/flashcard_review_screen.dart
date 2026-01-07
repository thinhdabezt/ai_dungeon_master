import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/learning_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/flashcard_model.dart';

class FlashcardReviewScreen extends StatefulWidget {
  const FlashcardReviewScreen({super.key});

  @override
  State<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends State<FlashcardReviewScreen> {
  int _currentIndex = 0;
  bool _isAnswerRevealed = false;
  List<FlashcardModel> _reviewQueue = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCards();
    });
  }

  Future<void> _loadCards() async {
    final provider = context.read<LearningProvider>();
    // Assume cards are loaded or load again
    if (provider.cards.isEmpty) {
        await provider.loadCards();
    }
    setState(() {
      _reviewQueue = List.from(provider.cards)..shuffle();
    });
  }

  void _handleRating(int rating) async {
    if (_currentIndex >= _reviewQueue.length) return;

    final card = _reviewQueue[_currentIndex];
    final learningProvider = context.read<LearningProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      final stats = await learningProvider.reviewCard(card.id, rating);
      
      if (stats['learningXP'] != null && stats['currentStreak'] != null) {
         authProvider.updateStats(stats['learningXP'], stats['currentStreak']);
      }

      if (mounted) {
        setState(() {
          _isAnswerRevealed = false;
          _currentIndex++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_reviewQueue.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Classic Review')),
        body: const Center(child: Text('Loading or No Cards...')),
      );
    }

    if (_currentIndex >= _reviewQueue.length) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
               const SizedBox(height: 24),
               const Text('Review Complete!'),
               const SizedBox(height: 16),
               ElevatedButton(
                 onPressed: () => Navigator.pop(context),
                 child: const Text('Back'),
               ),
            ],
          ),
        ),
      );
    }

    final card = _reviewQueue[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Classic (${_currentIndex + 1}/${_reviewQueue.length})'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _reviewQueue.length,
            backgroundColor: Colors.white10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: _isAnswerRevealed
                    ? _buildBackSide(card)
                    : _buildFrontSide(card),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.black12,
            child: SafeArea(
              child: _isAnswerRevealed
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRatingButton('Again', Colors.red, 1),
                        _buildRatingButton('Hard', Colors.orange, 2),
                        _buildRatingButton('Good', Colors.green, 3),
                        _buildRatingButton('Easy', Colors.blue, 4),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _isAnswerRevealed = true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Show Answer'),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontSide(FlashcardModel card) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          card.word,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn().scale(),
        const SizedBox(height: 24),
        const Text('?', style: TextStyle(fontSize: 48, color: Colors.white24)),
      ],
    );
  }

  Widget _buildBackSide(FlashcardModel card) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Text(card.word, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.amber)),
         const Divider(height: 32, indent: 48, endIndent: 48),
         Text(card.definition, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildRatingButton(String label, Color color, int rating) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () => _handleRating(rating),
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.2),
            foregroundColor: color,
            minimumSize: const Size(70, 70),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(label == 'Again' ? '1' : label == 'Hard' ? '2' : label == 'Good' ? '3' : '4'),
        ),
      ],
    );
  }
}
