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

  User({required this.id, required this.username, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }
}
