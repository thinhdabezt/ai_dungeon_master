import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/learning_provider.dart';

class GrimoireScreen extends StatefulWidget {
  const GrimoireScreen({super.key});

  @override
  State<GrimoireScreen> createState() => _GrimoireScreenState();
}

class _GrimoireScreenState extends State<GrimoireScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().loadCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('The Grimoire')),
      body: provider.isLoading && provider.cards.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.cards.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.cards.length,
                  itemBuilder: (context, index) {
                    final card = provider.cards[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withAlpha(50),
                          child: Text(
                             (card.word.isNotEmpty) ? card.word[0].toUpperCase() : '?',
                             style: TextStyle(color: Theme.of(context).primaryColor)
                          ),
                        ),
                        title: Text(card.word, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(card.definition, maxLines: 1, overflow: TextOverflow.ellipsis),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Definition', style: Theme.of(context).textTheme.labelSmall),
                                const SizedBox(height: 4),
                                Text(card.definition),
                                const SizedBox(height: 12),
                                if (card.contextSentence != null) ...[
                                   Text('In Context', style: Theme.of(context).textTheme.labelSmall),
                                   const SizedBox(height: 4),
                                   Text('"${card.contextSentence}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                                ]
                              ],
                            ),
                          )
                        ],
                      ),
                    ).animate().fadeIn(delay: (50 * index).ms).slideX();
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           const Icon(Icons.menu_book, size: 80, color: Colors.white24),
           const SizedBox(height: 16),
           const Text('Your Grimoire is empty.', style: TextStyle(color: Colors.white54, fontSize: 18)),
           const SizedBox(height: 8),
           const Text('Inspect messages in your adventures to collect knowledge.', style: TextStyle(color: Colors.white38)),
        ],
      ).animate().fade().scale(),
    );
  }
}
