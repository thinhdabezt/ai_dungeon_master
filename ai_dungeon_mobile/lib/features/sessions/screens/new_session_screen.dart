import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/theme_utils.dart';
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
      final newSession = await context.read<SessionProvider>().createSession(
            _titleController.text.trim(),
            _selectedTheme!.key,
          );
      
      if (newSession != null && mounted) {
        context.go('/'); // Clear stack to home? Or just go to home then push?
        // Better: Replace with home then push details, or simply push replacement if we want back button to go to home.
        // Let's use go('/home') then push.
        context.go('/home'); 
        context.push('/sessions/${newSession.id}', extra: newSession.title);
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
                      crossAxisCount: 3, // Changed to 3
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9, // Adjusted for 3x3
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
                            // Use distinct surface color (Grey) for cards
                            // Blend with the explicit violet color (0xFF8B5CF6) when selected
                            color: isSelected 
                                ? Color.alphaBlend(const Color(0xFF8B5CF6).withOpacity(0.25), const Color(0xFF1E1E1E))
                                : const Color(0xFF1E1E1E), 
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                ? const Color(0xFF8B5CF6) // Explicit Violet
                                : Colors.white12, 
                              width: isSelected ? 3 : 1, 
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
                                : [], 
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                ThemeUtils.getThemeIcon(theme.key),
                                size: 32,
                                color: isSelected ? const Color(0xFF8B5CF6) : Colors.white70, // Explicit Violet
                              ),
                              const SizedBox(height: 8),
                              Expanded( 
                                child: Center(
                                  child: Text(
                                    theme.name,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                      fontSize: 12, 
                                      color: isSelected ? const Color(0xFF8B5CF6) : Colors.white, // Explicit Violet
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              // Removed theme.description (AI prompt)
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
}
