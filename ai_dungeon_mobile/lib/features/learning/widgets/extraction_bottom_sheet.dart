import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../learning/providers/learning_provider.dart';
import '../../learning/models/vocabulary_extraction_dto.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExtractionBottomSheet extends StatefulWidget {
  final String text;
  final String? sessionId;

  const ExtractionBottomSheet({super.key, required this.text, this.sessionId});

  @override
  State<ExtractionBottomSheet> createState() => _ExtractionBottomSheetState();
}

class _ExtractionBottomSheetState extends State<ExtractionBottomSheet> {
  late Future<List<VocabularyExtractionDto>> _future;
  final Set<String> _savedWords = {};

  @override
  void initState() {
    super.initState();
    _future = context.read<LearningProvider>().extractVocabulary(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Arcane Knowledge', style: Theme.of(context).textTheme.titleLarge),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          Flexible(
            child: FutureBuilder<List<VocabularyExtractionDto>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Failed to extract: ${snapshot.error}'));
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(child: Text('No new knowledge found in this scroll.'));
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSaved = _savedWords.contains(item.word);
                    return ListTile(
                      tileColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Text(item.word, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('(${item.partOfSpeech}) ${item.definition}', style: const TextStyle(fontStyle: FontStyle.italic)),
                          const SizedBox(height: 4),
                          Text('"${item.context}"', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(isSaved ? Icons.check_circle : Icons.add_circle, // Filled icon for better visibility
                                   color: isSaved ? Colors.green : Colors.white), // White for contrast on dark card
                        onPressed: isSaved ? null : () async {
                           try {
                             await context.read<LearningProvider>().saveCard(
                               item.word, 
                               item.definition, 
                               item.context, 
                               widget.sessionId
                             );
                             setState(() {
                               _savedWords.add(item.word);
                             });
                             if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Grimoire')));
                           } catch (e) {
                             if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
                           }
                        },
                      ),
                    ).animate().fadeIn(delay: (100 * index).ms).slideX();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
