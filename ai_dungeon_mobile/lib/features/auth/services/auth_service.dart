import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/auth_models.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResponse> login(String usernameOrEmail, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      });
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      await _apiClient.dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getMe() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        return error.response?.data?.toString() ?? 'Server error';
      }
      return 'Network error: ${error.message}';
    }
    return 'Unknown error: $error';
  }

  Future<void> updateAvatar(String avatarUrl) async {
    try {
      await _apiClient.dio.patch('/auth/avatar', data: {
        'avatarUrl': avatarUrl,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetQuota() async {
    try {
      // Using sessions endpoint from auth service is slightly dirty but convenient
      await _apiClient.dio.post('/sessions/quota/reset');
    } catch (e) {
      throw _handleError(e);
    }
  }
}
