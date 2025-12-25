class SessionModel {
  final String id;
  final String userId;
  final String title;
  final String themeKey;
  final DateTime createdAt;
  final DateTime lastUpdated;

  SessionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.themeKey,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      themeKey: json['themeKey'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
