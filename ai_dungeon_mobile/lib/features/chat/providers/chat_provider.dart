import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../sessions/services/session_service.dart';
import '../models/message_model.dart';
import '../../sessions/models/session_model.dart';

class ChatProvider extends ChangeNotifier {
  final SessionService _sessionService;

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  String? _currentSessionId;

  SessionModel? _currentSession;

  ChatProvider(this._sessionService);

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  SessionModel? get currentSession => _currentSession;

  void setCurrentSession(String sessionId) {
    _currentSessionId = sessionId;
    _currentSession = null; // Reset
    _messages = [];
    _errorMessage = null;
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_currentSessionId == null) return;
    _setLoading(true);
    try {
      final session = await _sessionService.getSession(_currentSessionId!);
      _currentSession = session;
      _messages = session.messages;
      // Sort older to newer?
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load chat: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendMessage(String text, {bool includeHint = false}) async {
    if (_currentSessionId == null || text.trim().isEmpty) return;

    final userMsg = MessageModel(
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
    );

    _messages.add(userMsg);
    _isSending = true;
    notifyListeners();

    try {
      final dto = ChatRequestDto(input: text, includeHint: includeHint);
      final responseMap = await _sessionService.sendChat(_currentSessionId!, dto.toJson());
      
      // Parse AI response
      final aiMsg = MessageModel.fromJson(responseMap);
      _messages.add(aiMsg);
      
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      // Optionally remove the user message or mark as failed
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  Future<void> exportTranscript() async {
    if (_messages.isEmpty) return;

    final sb = StringBuffer();
    sb.writeln('Adventure Transcript');
    sb.writeln('-------------------');
    sb.writeln();

    for (final msg in _messages) {
      if (msg.isUser) {
        sb.writeln('**Player**: ${msg.content}');
      } else {
        sb.writeln('**DM**: ${msg.content}');
      }
      sb.writeln();
    }

    final transcript = sb.toString();
    await Share.share(transcript, subject: 'AI Dungeon Transcript');
  }
}
