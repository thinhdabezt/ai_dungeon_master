import 'package:flutter/material.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final SecureStorageService _storageService;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  User? _currentUser;
  String? _errorMessage;

  AuthProvider(this._authService, this._storageService);

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthStatus() async {
    final token = await _storageService.getToken();
    if (token != null) {
      try {
        _isAuthenticated = true;
        // Optionally fetch user details here
         _currentUser = await _authService.getMe();
        notifyListeners();
      } catch (e) {
        // Token invalid or expired
        await logout();
      }
    } else {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await _authService.login(username, password);
      await _storageService.saveToken(response.accessToken);
      if (response.refreshToken != null) {
        await _storageService.saveRefreshToken(response.refreshToken!);
      }
      _isAuthenticated = true;
      
      // Fetch user info immediately
      try {
        _currentUser = await _authService.getMe();
      } catch (_) {
        // Non-critical if fails right now
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.register(username, email, password);
      _setLoading(false);
      return true; // Registration successful
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void updateStats(int xp, int streak) {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        username: _currentUser!.username,
        email: _currentUser!.email,
        learningXP: xp,
        currentStreak: streak,
        lastStudyDate: DateTime.now(), // Optimistic update
      );
      notifyListeners();
    }
  }

  Future<void> updateAvatar(String avatarUrl) async {
    try {
      await _authService.updateAvatar(avatarUrl);
      // Optimistic update
      if (_currentUser != null) {
        _currentUser = User(
          id: _currentUser!.id,
          username: _currentUser!.username,
          email: _currentUser!.email,
          learningXP: _currentUser!.learningXP,
          currentStreak: _currentUser!.currentStreak,
          lastStudyDate: _currentUser!.lastStudyDate,
          avatarUrl: avatarUrl,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
