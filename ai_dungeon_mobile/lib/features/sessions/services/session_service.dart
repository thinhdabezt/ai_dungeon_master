import '../../../core/storage/cache_service.dart';
import '../../../core/network/api_client.dart';
import '../models/create_session_dto.dart';
import '../models/session_model.dart';
import '../models/theme_model.dart';

class SessionService {
  final ApiClient _apiClient;
  final CacheService _cacheService;

  SessionService(this._apiClient, this._cacheService);

  Future<List<ThemeModel>> getThemes() async {
    try {
      final response = await _apiClient.dio.get('/themes');
      final List<dynamic> data = response.data;
      final themes = data.map((json) => ThemeModel.fromJson(json)).toList();
      _cacheService.saveThemes(themes);
      return themes;
    } catch (e) {
      final cached = await _cacheService.getThemes();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<List<SessionModel>> getSessions() async {
    try {
      final response = await _apiClient.dio.get('/sessions');
      // The backend adds pagination, but if we just get a list, we treat it as such.
      // If backend returns { items: [], total: ... }, we need to adjust.
      // Based on typical simple implementations, it might just be the list or a paginated response.
      // Checking backend controller...
      // Backend: return Ok(await _sessionService.GetUserSessionsAsync(userId)); -> Returns IEnumerable<StorySessionDto> logic?
      // Actually Controller says: return Ok(sessions); where sessions is List<StorySessionDto>.
      
      final List<dynamic> data = response.data;
      final sessions = data.map((json) => SessionModel.fromJson(json)).toList();
      _cacheService.saveSessions(sessions);
      return sessions;
    } catch (e) {
      final cached = await _cacheService.getSessions();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<SessionModel> createSession(CreateSessionDto dto) async {
    try {
      final response = await _apiClient.dio.post(
        '/sessions',
        data: dto.toJson(),
      );
      return SessionModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      await _apiClient.dio.delete('/sessions/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> renameSession(String id, String newTitle) async {
    try {
      await _apiClient.dio.patch(
        '/sessions/$id/title',
        data: {'newTitle': newTitle},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches messages for a specific session.
  /// Note: Verify if backend has a dedicated endpoint or if we need to expand GET /sessions/{id}.
  /// As per B3: endpoint GET /api/sessions/{id} returns StorySessionDto which likely includes Messages.
  Future<SessionModel> getSession(String id) async {
    try {
      final response = await _apiClient.dio.get('/sessions/$id');
      final session = SessionModel.fromJson(response.data);
      _cacheService.saveSessionDetail(session);
      return session;
    } catch (e) {
      final cached = await _cacheService.getSessionDetail(id);
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Sends a chat message.
  /// Returns the AI's response as a SessionMessage (or compatible DTO).
  Future<Map<String, dynamic>> sendChat(String sessionId, Map<String, dynamic> dto) async {
    try {
      final response = await _apiClient.dio.post(
        '/sessions/$sessionId/chat',
        data: dto,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

