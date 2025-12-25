import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/session_provider.dart';
import '../models/theme_model.dart'; // Import ThemeModel

class NewSessionScreen extends StatefulWidget {
  const NewSessionScreen({super.key});

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  ThemeModel? _selectedTheme; // Use ThemeModel for type safety

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionProvider>().loadThemes();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedTheme != null) {
      final success = await context.read<SessionProvider>().createSession(
            _titleController.text.trim(),
            _selectedTheme!.key,
          );
      
      if (success && mounted) {
        context.pop(); // Go back to list
      } else if (mounted) {
        final error = context.read<SessionProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to create session')),
        );
      }
    } else if (_selectedTheme == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a theme')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('New Adventure')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adventure Config',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              // TITLE INPUT
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Adventure Title',
                  hintText: 'e.g., The Lost City of Gold',
                  prefixIcon: Icon(Icons.edit),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // THEME SELECTOR
              Text(
                'Select Theme',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              
              if (provider.isLoading && provider.themes.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ))
              else if (provider.themes.isEmpty)
                const Text('No themes available.')
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8, // Taller cards
                  ),
                  itemCount: provider.themes.length,
                  itemBuilder: (context, index) {
                    final theme = provider.themes[index];
                    final isSelected = _selectedTheme == theme;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTheme = theme;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Theme.of(context).primaryColor.withAlpha(50) 
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Theme.of(context).primaryColor.withAlpha(100), blurRadius: 8)]
                              : [],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Placeholder Icon/Image based on theme name logic or generic
                            Icon(
                              _getThemeIcon(theme.key),
                              size: 32,
                              color: isSelected ? Theme.of(context).primaryColor : Colors.white70,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              theme.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                theme.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: Colors.white54,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().scale(delay: (50*index).ms);
                  },
                ),
                
              const SizedBox(height: 32),
              
              // CREATE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Text('Start Adventure'),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getThemeIcon(String key) {
    switch (key.toLowerCase()) {
      case 'fantasy': return Icons.auto_awesome;
      case 'sci-fi': return Icons.rocket_launch;
      case 'mystery': return Icons.search;
      case 'horror': return Icons.local_fire_department; // or something scary
      case 'steampunk': return Icons.settings;
      case 'cyberpunk': return Icons.memory;
      case 'historical': return Icons.history_edu;
      case 'post-apocalyptic': return Icons.warning;
      case 'western': return Icons.explore; // temporary
      default: return Icons.category;
    }
  }
}
