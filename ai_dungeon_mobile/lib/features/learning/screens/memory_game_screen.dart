import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../providers/learning_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/flashcard_model.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late List<String> _items; 
  late Map<String, String> _pairs; 
  
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
    final cards = List<FlashcardModel>.from(provider.cards)..shuffle();
    final gameCards = cards.take(6).toList(); // 6 pairs = 12 cards

    _pairs = {};
    _items = [];

    for (var card in gameCards) {
      String wordKey = "W:${card.word}";
      String defKey = "D:${card.word}"; // Key by content for display, actually let's use word for both sides? No, pair word with definition.

      // Actually, standard memory game usually pairs identical images.
      // But for learning, pairing Word <-> Definition is harder/better.
      // Let's stick to Word <-> Definition.
      
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

      if (_pairs[item1] == _pairs[item2]) {
        // Match
        await Future.delayed(500.ms);
        setState(() {
          _matchedItems.add(item1);
          _matchedItems.add(item2);
          _selectedItems.clear();
          _isProcessing = false;
        });
      } else {
        // No Match
        await Future.delayed(1000.ms);
        setState(() {
          _selectedItems.clear();
          _isProcessing = false;
        });
      }

      if (_matchedItems.length == _items.length) {
         _handleWin();
      }
    }
  }

  Future<void> _handleWin() async {
    final authProvider = context.read<AuthProvider>();
    authProvider.updateStats((authProvider.currentUser?.learningXP ?? 0) + 60, (authProvider.currentUser?.currentStreak ?? 0));

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Memory Master!'),
        content: const Text('All pairs found! +60 XP'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Finish'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mind Flip')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            final isOpen = _selectedItems.contains(item) || _matchedItems.contains(item);
            final text = item.startsWith("W:") ? item.substring(2) : "Definition..."; 
            // Only show full definition if open
            final content = item.startsWith("W:") ? item.substring(2) : 
                // We need to look up definition? 
                // Wait, item string is key. Ideally we store object.
                // Let's Hack: item string for definition is just "D:${card.id}"? No i used "D:${card.word}"
                // I need the definition text.
                // Let's refactor _items to object later. For now, matching game approach was cleaner.
                // I'll grab definition from provider if needed, or just store text in key? 
                // "D:${definition}" might be too long for key? 
                // It's memory, so context is small card.
                // Let's use simple icon for definition side? Or just shortened text.
                // Re-reading logic: `String defKey = "D:${card.word}";` <-- This is wrong, it just shows word again?
                // I need actual definition.
                // Let's fix this builder logic.
                
                // For now, let's just use Text and Icon?
                // Word Card: Text(Word)
                // Def Card: Icon(Book) ... Wait, user needs to match word to definition without seeing definition? That's impossible.
                // User must see definition when flipped.
                "Definition"; // Placeholder, need actual text.
            
            return GestureDetector(
              onTap: () => _handleSelection(item),
              child: AnimatedContainer(
                duration: 400.ms,
                curve: Curves.easeOutBack,
                transform: Matrix4.identity()..rotateY(isOpen ? 0 : pi), // Simple flip simulation
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isOpen ? Theme.of(context).cardColor : Colors.indigo.shade900,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                alignment: Alignment.center,
                child: isOpen 
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(0), // Ensure text is upright? Flip effect needs conditional builder
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          _getItemText(item), // Helper
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
                          maxLines: 4,
                        ),
                      ),
                    )
                  : const Icon(Icons.help_outline, color: Colors.white24),
              ),
            );
          },
        ),
      ),
    );
  }
  
  String _getItemText(String item) {
    final provider = context.read<LearningProvider>();
    // This is inefficient O(N) lookup every render, but N=12.
    // Parse ID from map?
    // I stored "W:Word" and "D:Word".
    // I need to find the card.
    
    // Better: _items should be a Class `GameItem { id, text, type }`.
    // Fixing setup first.
    
    if (item.startsWith("W:")) return item.substring(2);
    
    // It's a definition card, key was "D:Word" (my bad in setup)
    String word = item.substring(2);
    final card = provider.cards.firstWhere((c) => c.word == word, orElse: () => FlashcardModel(id: '', word: 'Error', definition: '', createdAt: DateTime.now()));
    return card.definition;
  }
}
