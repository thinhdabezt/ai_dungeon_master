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

  Future<SessionModel?> createSession(String title, String themeKey, {String ieltsBand = "9.0"}) async {
    _setLoading(true);
    try {
      final dto = CreateSessionDto(title: title, themeKey: themeKey, ieltsBand: ieltsBand);
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


  Future<void> renameSession(String id, String newTitle) async {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final oldSession = _sessions[index];
    // Create new session object with updated title to trigger selector updates if any (immutable style)
    // Actually SessionModel fields are final, so we prefer creating a new instance or using copyWith if it existed.
    // Let's create a new instance manually for now or just trust loadSessions?
    // Optimistic update:
    // We don't have copyWith, so let's skip deep immutable update and arguably "mutate" if we removed final? No.
    // We will refresh the list or wait.
    // Better: Add copyWith to SessionModel later. For now, we will just fetch list again or hack it.
    // Let's assume we implement copyWith or just generic field update if we can't.
    // Wait, let's implement copyWith on SessionModel first or just refetch.
    // Refetching is safer but slower. 
    // Let's optimistic update by replacing the item in the list.
    
    // We'll modify SessionModel to have copyWith in a sec.
    
    try {
      await _sessionService.renameSession(id, newTitle);
      // If success, reload
      await loadSessions();
    } catch (e) {
      _errorMessage = 'Failed to rename session: $e';
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
