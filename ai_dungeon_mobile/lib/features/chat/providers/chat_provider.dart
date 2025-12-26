import 'package:flutter/material.dart';
import '../../sessions/services/session_service.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final SessionService _sessionService;

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  String? _currentSessionId;

  ChatProvider(this._sessionService);

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  void setCurrentSession(String sessionId) {
    _currentSessionId = sessionId;
    _messages = [];
    _errorMessage = null;
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_currentSessionId == null) return;
    _setLoading(true);
    try {
      final session = await _sessionService.getSession(_currentSessionId!);
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
}
