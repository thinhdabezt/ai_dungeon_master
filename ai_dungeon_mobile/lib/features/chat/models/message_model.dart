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
    // Backend 'Role' enum: User = 0, DungeonMaster = 1, System = 2
    // We'll treat DM and System as !isUser
    // The backend might return 'Role' as integer or string depending on serializer
    // Let's assume int based on standard EF Core, or check DTOs.
    // Actually, looking at previous DTOs, it acts as a standard JSON return.
    
    final role = json['role'];
    final isUser = (role == 0 || role == 'User'); 
    
    return MessageModel(
      id: json['id']?.toString(),
      content: json['content'] ?? '',
      isUser: isUser,
      hint: json['hint'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      tokenCount: json['tokenCount'] ?? 0,
    );
  }
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
