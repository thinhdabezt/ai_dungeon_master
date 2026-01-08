import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final VoidCallback? onInspect;
  final Set<String>? highlightWords;
  final String? userAvatarUrl;
  final IconData? dmIcon;

  const ChatBubble({
    super.key, 
    required this.message, 
    this.onInspect,
    this.highlightWords,
    this.userAvatarUrl,
    this.dmIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);

    // Avatar Widget
    Widget avatarWidget;
    if (isUser) {
      avatarWidget = CircleAvatar(
        radius: 16,
        backgroundColor: theme.primaryColorDark,
        backgroundImage: userAvatarUrl != null ? NetworkImage(userAvatarUrl!) : null,
        child: userAvatarUrl == null ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 16,
        backgroundColor: Colors.amber.withOpacity(0.2),
        child: Icon(dmIcon ?? Icons.auto_awesome, size: 16, color: Colors.amber),
      );
    }

    // Message Content contentWidget... 
    // (We reuse the container logic but wrap in Row)
    
    Widget bubbleContent = Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75, // Reduced for avatar
        ),
        decoration: BoxDecoration(
          color: isUser 
              ? theme.primaryColor 
              : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
            topRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
          border: isUser ? null : Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUser)
              Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              )
            else

                Builder(
                  builder: (context) {
                    // Pre-process content to bold matching words
                    String processedContent = message.content;
                    if (highlightWords != null) {
                      for (final word in highlightWords!) {
                        // Case-insensitive replacement using Regex
                        processedContent = processedContent.replaceAllMapped(
                          RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false),
                          (match) => '**${match.group(0)}**',
                        );
                      }
                    }

                    return MarkdownBody(
                      data: processedContent,
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        p: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          height: 1.5,
                        ),
                        strong: TextStyle(
                          color: Colors.amber, 
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.amber.withOpacity(0.2)
                        ),
                      ),
                    );
                  }
                ),
            
            // Hint Display
            if (!isUser && message.hint != null && message.hint!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withAlpha(50)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message.hint!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.amber[200],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ],
            
            // Knowledge Inspection Button
            if (!isUser) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onInspect,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, // Changed to white as requested
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: Colors.white.withOpacity(0.1), // Subtle white background
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Inspect World'),
                ),
              ),
            ],
          ],
        ),
      );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Padding(padding: const EdgeInsets.only(top: 4), child: avatarWidget),
          ],
          bubbleContent,
          if (isUser) ...[
             Padding(padding: const EdgeInsets.only(top: 4), child: avatarWidget),
          ],
        ],
      )
    ).animate().fade(duration: 300.ms).slideY(begin: 0.2);
  }
}
