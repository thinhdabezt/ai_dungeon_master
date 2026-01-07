class AuthResponse {
  final String accessToken;
  final String? refreshToken;

  AuthResponse({required this.accessToken, this.refreshToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? json['token'] ?? '', // Handle varied naming if needed
      refreshToken: json['refreshToken'],
    );
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final int learningXP;
  final int currentStreak;
  final DateTime? lastStudyDate;

  User({
    required this.id, 
    required this.username, 
    required this.email,
    this.learningXP = 0,
    this.currentStreak = 0,
    this.lastStudyDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      learningXP: json['learningXP'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      lastStudyDate: json['lastStudyDate'] != null ? DateTime.parse(json['lastStudyDate']) : null,
    );
  }
}
