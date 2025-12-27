import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/sessions/models/session_model.dart';
import '../../features/sessions/models/theme_model.dart';

class CacheService {
  static const String keyThemes = 'cached_themes';
  static const String keySessions = 'cached_sessions';
  static const String keySessionPrefix = 'cached_session_';

  Future<void> saveThemes(List<ThemeModel> themes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = themes.map((t) => t.toJson()).toList();
    await prefs.setString(keyThemes, jsonEncode(jsonList));
  }

  Future<List<ThemeModel>> getThemes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(keyThemes);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((j) => ThemeModel.fromJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveSessions(List<SessionModel> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    // Save only summary (messages might be too large for list view)
    // Actually SessionModel includes summary, but maybe we should strip messages 
    // to save space if the list is huge. 
    // For now, save as is, but maybe limit count?
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(keySessions, jsonEncode(jsonList));
  }

  Future<List<SessionModel>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(keySessions);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((j) => SessionModel.fromJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveSessionDetail(SessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$keySessionPrefix${session.id}', jsonEncode(session.toJson()));
  }

  Future<SessionModel?> getSessionDetail(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$keySessionPrefix$id');
    if (jsonString == null) return null;

    try {
      return SessionModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }
}
