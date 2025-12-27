class MessageModel {
  final String? id;
  final String content;
  final bool isUser;
  final String? hint;
  final DateTime timestamp;
  final int tokenCount;

  MessageModel({
    this.id,
    required this.content,
    required this.isUser,
    this.hint,
    required this.timestamp,
    this.tokenCount = 0,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final role = json['role'];
    // Handle 'player' string (from backend) or legacy 0/1/User
    final isUser = (role == 'player' || role == 'User' || role == 0); 
    
    return MessageModel(
      id: json['id']?.toString(),
      content: json['content'] ?? '',
      isUser: isUser,
      hint: json['hint'],
      timestamp: DateTime.tryParse(json['createdAt'] ?? json['timestamp'] ?? '') ?? DateTime.now(), // Backend uses CreatedAt
      tokenCount: json['tokenCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'role': isUser ? 'player' : 'dm',
    'hint': hint,
    'timestamp': timestamp.toIso8601String(),
    'createdAt': timestamp.toIso8601String(),
    'tokenCount': tokenCount,
  };
}

class ChatRequestDto {
  final String input;
  final bool includeHint;

  ChatRequestDto({required this.input, this.includeHint = false});

  Map<String, dynamic> toJson() => {
        'input': input,
        'includeHint': includeHint,
      };
}
