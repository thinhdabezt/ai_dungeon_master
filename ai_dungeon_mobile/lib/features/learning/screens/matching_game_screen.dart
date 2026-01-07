import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/learning_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/flashcard_model.dart';

class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  late List<String> _items; // Contains both words and definitions
  late Map<String, String> _pairs; // Map item -> matchingId (cardId)
  
  List<String> _selectedItems = [];
  List<String> _matchedItems = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    final provider = context.read<LearningProvider>();
    // Take random 5 cards
    final cards = List<FlashcardModel>.from(provider.cards)..shuffle();
    final gameCards = cards.take(5).toList();

    _pairs = {};
    _items = [];

    for (var card in gameCards) {
      // We identify items by a unique prefix + content to avoid collision if word == def
      // But for simplicity of matching:
      // Item 1: "WORD:${card.word}" -> ID: card.id
      // Item 2: "DEF:${card.definition}" -> ID: card.id
      
      String wordKey = "W:${card.word}";
      String defKey = "D:${card.definition}";

      _pairs[wordKey] = card.id;
      _pairs[defKey] = card.id;
      
      _items.add(wordKey);
      _items.add(defKey);
    }

    _items.shuffle();
  }

  Future<void> _handleSelection(String item) async {
    if (_isProcessing || _matchedItems.contains(item) || _selectedItems.contains(item)) return;

    setState(() {
      _selectedItems.add(item);
    });

    if (_selectedItems.length == 2) {
      _isProcessing = true;
      final item1 = _selectedItems[0];
      final item2 = _selectedItems[1];

      // Check match
      if (_pairs[item1] == _pairs[item2]) {
        // Match!
        await Future.delayed(200.ms); // Visual feedback
        setState(() {
          _matchedItems.add(item1);
          _matchedItems.add(item2);
          _selectedItems.clear();
          _isProcessing = false;
        });
        
        // Award XP logic here?
        // _submitMatch(_pairs[item1]!);

      } else {
        // No match
        await Future.delayed(500.ms); // Show error
        setState(() {
          _selectedItems.clear();
          _isProcessing = false;
        });
      }
      
      // Check Win
      if (_matchedItems.length == _items.length) {
        _handleWin();
      }
    }
  }

  Future<void> _handleWin() async {
    // Award XP for the session
    // For now simple alert
    final authProvider = context.read<AuthProvider>();
    // Assume each pair is 10 XP? 5 cards * 10 = 50 XP
    authProvider.updateStats((authProvider.currentUser?.learningXP ?? 0) + 50, (authProvider.currentUser?.currentStreak ?? 0));
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Victory!'),
        content: const Text('You matched all terms! +50 XP'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Back to menu
            },
            child: const Text('Awesome'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rune Match')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate grid ratio
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final isSelected = _selectedItems.contains(item);
                final isMatched = _matchedItems.contains(item);
                final text = item.substring(2); // Remove prefix
                final isWord = item.startsWith("W:");

                return GestureDetector(
                  onTap: () => _handleSelection(item),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    decoration: BoxDecoration(
                      color: isMatched 
                          ? Colors.green.withOpacity(0.2)
                          : isSelected 
                              ? Colors.amber.withOpacity(0.3)
                              : Theme.of(context).cardColor,
                      border: Border.all(
                        color: isMatched 
                            ? Colors.green 
                            : isSelected 
                                ? Colors.amber 
                                : Colors.white24,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: isWord ? FontWeight.bold : FontWeight.normal,
                        color: isMatched ? Colors.greenAccent : Colors.white,
                        fontSize: isWord ? 16 : 14,
                      ),
                    ),
                  ).animate(target: isMatched ? 1 : 0).shimmer(duration: 400.ms),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
