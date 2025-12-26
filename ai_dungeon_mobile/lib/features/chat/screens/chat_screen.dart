import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Adventure'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show session details / settings
            },
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
                          return ChatBubble(message: chatProvider.messages[index]);
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
