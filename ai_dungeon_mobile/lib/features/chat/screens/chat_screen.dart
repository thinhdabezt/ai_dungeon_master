import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../../learning/widgets/extraction_bottom_sheet.dart';
import '../../learning/providers/learning_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/theme_utils.dart';

class ChatScreen extends StatefulWidget {
  final String sessionId;
  final String? title; // Optional, passed from navigation

  const ChatScreen({
    super.key,
    required this.sessionId,
    this.title,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().setCurrentSession(widget.sessionId);
      context.read<LearningProvider>().loadCards();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100, // Extra scroll
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    // Auto-scroll on new message
    // We can use a listener or just do it in the build if length changed, but careful with loops.
    // Better to hook into the provider or check didUpdateWidget/listen.
    // For simplicity, we'll try to scroll on post-frame if not loading.
    
    // Listen for errors
    if (chatProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(chatProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        // We might want to clear the error so it doesn't show repeatedly, 
        // but ChatProvider doesn't have a clearError method exposed nicely aside from reload.
        // Ideally ChatProvider clears it after consumption or we add a method.
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Adventure'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export') {
                context.read<ChatProvider>().exportTranscript();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Export Transcript'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.isLoading && chatProvider.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : chatProvider.messages.isEmpty
                    ? const Center(child: Text('The story begins...'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        itemCount: chatProvider.messages.length + (chatProvider.isSending ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == chatProvider.messages.length) {
                             // Typing indicator
                             return const Padding(
                               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                               child: Text(
                                 'The Dungeon Master is thinking...',
                                 style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white54),
                               ),
                             );
                          }
                          final learningProvider = context.watch<LearningProvider>();
                          final authProvider = context.watch<AuthProvider>();
                          final themeKey = chatProvider.currentSession?.themeKey ?? 'classic_high_fantasy';
                          
                          return ChatBubble(
                            message: chatProvider.messages[index],
                            highlightWords: learningProvider.cards.map((c) => c.word).toSet(),
                            userAvatarUrl: authProvider.currentUser?.avatarUrl,
                            dmIcon: ThemeUtils.getThemeIcon(themeKey),
                            onInspect: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (ctx) => ExtractionBottomSheet(
                                  text: chatProvider.messages[index].content,
                                  sessionId: widget.sessionId,
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
          ChatInput(
            isLoading: chatProvider.isSending,
            onSend: (text, includeHint) async {
              await chatProvider.sendMessage(text, includeHint: includeHint);
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }
}
