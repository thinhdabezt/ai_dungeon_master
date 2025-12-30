import '../../chat/models/message_model.dart';

class SessionModel {
  final String id;
  final String userId;
  final String title;
  final String themeKey;
  final DateTime createdAt;
  final DateTime lastUpdated;

  final List<MessageModel> messages;
  final int dailyTokensUsed;
  final int maxTokens;

  SessionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.themeKey,
    required this.createdAt,
    required this.lastUpdated,
    this.messages = const [],
    this.dailyTokensUsed = 0,
    this.maxTokens = 50000,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      themeKey: json['themeKey'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => MessageModel.fromJson(e))
              .toList() ??
          [],

      dailyTokensUsed: json['dailyTokensUsed'] ?? 0,
      maxTokens: json['maxTokens'] ?? 50000,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'themeKey': themeKey,
    'createdAt': createdAt.toIso8601String(),
    'lastUpdated': lastUpdated.toIso8601String(),
    'messages': messages.map((e) => e.toJson()).toList(),
    'dailyTokensUsed': dailyTokensUsed,
    'maxTokens': maxTokens,
  };
}

