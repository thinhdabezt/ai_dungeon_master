import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'flashcard_review_screen.dart';
import 'matching_game_screen.dart';
import 'memory_game_screen.dart';

import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    
    // Check if review done today
    bool isDailyReviewDone = false;
    if (user?.lastStudyDate != null) {
      final now = DateTime.now();
      final last = user!.lastStudyDate!.toLocal();
      if (now.year == last.year && now.month == last.month && now.day == last.day) {
        isDailyReviewDone = true;
      }
    }

    if (isDailyReviewDone) {
       return Scaffold(
        appBar: AppBar(title: const Text('Review Complete')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.check_circle, size: 80, color: Colors.green).animate().scale(),
               const SizedBox(height: 24),
               Text('Daily Limit Reached', style: Theme.of(context).textTheme.headlineMedium),
               const SizedBox(height: 16),
               const Text('You have gathered your mana for today.', style: TextStyle(color: Colors.white60)),
               const SizedBox(height: 8),
               const Text('Come back tomorrow for more XP!', style: TextStyle(color: Colors.white38)),
               const SizedBox(height: 32),
               ElevatedButton(
                 onPressed: () => Navigator.pop(context),
                 child: const Text('Return to Grimoire'),
               ),
            ],
          ),
        ),
       );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Trial')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGameOption(
                context,
                title: 'Classic Review',
                subtitle: 'Standard Flashcards',
                icon: Icons.style,
                color: Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardReviewScreen())),
              ),
              const SizedBox(height: 16),
              _buildGameOption(
                context,
                title: 'Rune Match',
                subtitle: 'Match Words to Meanings',
                icon: Icons.link,
                color: Colors.amber,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchingGameScreen())),
              ),
              const SizedBox(height: 16),
              _buildGameOption(
                context,
                title: 'Mind Flip',
                subtitle: 'Memory Card Game',
                icon: Icons.grid_view,
                color: Colors.purple,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGameScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOption(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }
}
