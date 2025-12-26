import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String, bool) onSend; // text, includeHint
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.onSend,
    required this.isLoading,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _includeHint = false;

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSend(text, _includeHint);
      _controller.clear();
      // Keep hint preference or reset? Let's reset for now to save tokens.
      // Or keep it if the user wants hints continuously? 
      // User Settings usually controls the default, but this is a per-message override.
      // Let's keep it unchecked by default each time unless we persist state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'What do you do?',
                      fillColor: Theme.of(context).cardColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.isLoading ? null : _handleSend,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: widget.isLoading 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                 FilterChip(
                  label: const Text('Request Hint'),
                  selected: _includeHint,
                  onSelected: (bool selected) {
                    setState(() {
                      _includeHint = selected;
                    });
                  },
                  visualDensity: VisualDensity.compact,
                  showCheckmark: true,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
