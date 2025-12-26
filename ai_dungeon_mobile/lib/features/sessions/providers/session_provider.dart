import 'package:flutter/material.dart';
import '../models/create_session_dto.dart';
import '../models/session_model.dart';
import '../models/theme_model.dart';
import '../services/session_service.dart';

class SessionProvider extends ChangeNotifier {
  final SessionService _sessionService;

  List<ThemeModel> _themes = [];
  List<SessionModel> _sessions = [];
  bool _isLoading = false;
  String? _errorMessage;

  SessionProvider(this._sessionService);

  List<ThemeModel> get themes => _themes;
  List<SessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadThemes() async {
    if (_themes.isNotEmpty) return; // Cache checks

    _setLoading(true);
    try {
      _themes = await _sessionService.getThemes();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load themes: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSessions() async {
    _setLoading(true);
    try {
      _sessions = await _sessionService.getSessions();
      // Sort sessions by lastUpdated descending
      _sessions.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load sessions: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<SessionModel?> createSession(String title, String themeKey) async {
    _setLoading(true);
    try {
      final dto = CreateSessionDto(title: title, themeKey: themeKey);
      final newSession = await _sessionService.createSession(dto);
      _sessions.insert(0, newSession);
      _errorMessage = null;
      notifyListeners();
      return newSession;
    } catch (e) {
      _errorMessage = 'Failed to create session: $e';
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteSession(String id) async {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final removedSession = _sessions[index];
    _sessions.removeAt(index);
    notifyListeners();

    try {
      await _sessionService.deleteSession(id);
    } catch (e) {
      // Revert if failed
      _sessions.insert(index, removedSession);
      _errorMessage = 'Failed to delete session: $e';
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
