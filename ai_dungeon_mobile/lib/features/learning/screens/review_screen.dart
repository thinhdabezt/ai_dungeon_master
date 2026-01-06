import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/learning_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/flashcard_model.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
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
    await provider.loadCards();
    setState(() {
      // For P7 SRS, we would filter by nextReviewDate.
      // For now, we take all cards or just shuffle them.
      _reviewQueue = List.from(provider.cards)..shuffle();
      // _reviewQueue = _reviewQueue.take(10).toList(); // Limit session size
    });
  }

  void _handleRating(int rating) async {
    if (_currentIndex >= _reviewQueue.length) return;

    final card = _reviewQueue[_currentIndex];
    final learningProvider = context.read<LearningProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      final stats = await learningProvider.reviewCard(card.id, rating);
      
      // Update User Stats (XP/Streak)
      if (stats['learningXP'] != null && stats['currentStreak'] != null) {
         authProvider.updateStats(stats['learningXP'], stats['currentStreak']);
      }

      // Move to next card
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
      // Loading or Empty
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: const Center(child: Text('No cards to review yet! Add some words first.')),
      );
    }

    if (_currentIndex >= _reviewQueue.length) {
      // Finished
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 80, color: Colors.green)
                  .animate().scale(duration: 500.ms),
              const SizedBox(height: 24),
              Text('Session Complete!', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Return to Grimoire'),
              ),
            ],
          ),
        ),
      );
    }

    final card = _reviewQueue[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Review (${_currentIndex + 1}/${_reviewQueue.length})'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Bar
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

          // Controls
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
            color: Colors.amber, // Magic feel
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn().scale(),
        const SizedBox(height: 24),
        const Text(
          '?',
          style: TextStyle(fontSize: 48, color: Colors.white24),
        ),
      ],
    );
  }

  Widget _buildBackSide(FlashcardModel card) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          card.word,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.amber,
          ),
        ),
        const Divider(height: 32, indent: 48, endIndent: 48),
        Text(
          card.definition,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ).animate().fadeIn(),
        if (card.contextSentence != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              '"${card.contextSentence}"',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
            foregroundColor: color, // Text color
            minimumSize: const Size(70, 70), // Square-ish
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            side: BorderSide(color: color.withOpacity(0.5)),
          ),
          child: Text(
             // Show approx interval logic if we had it, for now just simpler icon or label
             label == 'Again' ? '1' : label == 'Hard' ? '2' : label == 'Good' ? '3' : '4',
             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
