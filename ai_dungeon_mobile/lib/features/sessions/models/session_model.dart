import '../../chat/models/message_model.dart';

class SessionModel {
  final String id;
  final String userId;
  final String title;
  final String themeKey;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final List<MessageModel> messages;

  SessionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.themeKey,
    required this.createdAt,
    required this.lastUpdated,
    this.messages = const [],
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
  };
}

