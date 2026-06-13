import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/chat_models.dart';
import '../data/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final _service = ChatService();

  List<ChatConversation> _conversations = [];
  List<ChatMessage> _messages = [];
  int _totalUnread = 0;
  bool _loading = false;

  List<ChatConversation> get conversations => _conversations;
  List<ChatMessage> get messages => _messages;
  int get totalUnread => _totalUnread;
  bool get loading => _loading;

  StreamSubscription<List<ChatConversation>>? _convSub;
  StreamSubscription<List<ChatMessage>>? _msgSub;
  StreamSubscription<int>? _unreadSub;

  // ── Start listening to all conversations for the logged-in user ──────────
  void listenConversations(String userId, bool isCoach) {
    _convSub?.cancel();
    _unreadSub?.cancel();

    _convSub = _service.conversationsStream(userId, isCoach).listen(
      (list) {
        _conversations = list;
        notifyListeners();
      },
      onError: (e) => debugPrint('conversationsStream error: $e'),
    );

    _unreadSub = _service.totalUnreadStream(userId, isCoach).listen(
      (count) {
        _totalUnread = count;
        notifyListeners();
      },
      onError: (e) => debugPrint('totalUnreadStream error: $e'),
    );
  }

  // ── Start listening to messages in one conversation ──────────────────────
  void listenMessages(String conversationId) {
    _msgSub?.cancel();
    _msgSub = _service.messagesStream(conversationId).listen(
      (list) {
        _messages = list;
        notifyListeners();
      },
      onError: (e) => debugPrint('messagesStream error: $e'),
    );
  }

  void clearMessages() {
    _msgSub?.cancel();
    _messages = [];
    notifyListeners();
  }

  /// Stop all Firestore listeners and reset state (call on logout).
  void stopListening() {
    _convSub?.cancel();
    _msgSub?.cancel();
    _unreadSub?.cancel();
    _conversations = [];
    _messages = [];
    _totalUnread = 0;
    notifyListeners();
  }

  // ── Ensure a conversation doc exists before opening chat ────────────────
  Future<void> openOrCreateConversation({
    required String coachId,
    required String traineeId,
    required String coachName,
    required String traineeName,
    required String gymId,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      await _service.ensureConversation(
        coachId: coachId,
        traineeId: traineeId,
        coachName: coachName,
        traineeName: traineeName,
        gymId: gymId,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Send a message ───────────────────────────────────────────────────────
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    required bool senderIsCoach,
    required String recipientId,
    String? contextType,
    String? contextId,
    String? contextLabel,
  }) async {
    if (text.trim().isEmpty) return;
    await _service.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text.trim(),
      senderIsCoach: senderIsCoach,
      recipientId: recipientId,
      contextType: contextType,
      contextId: contextId,
      contextLabel: contextLabel,
    );
  }

  // ── Mark conversation as read ────────────────────────────────────────────
  Future<void> markRead(
      String conversationId, bool isCoach, String currentUserId) async {
    await _service.markRead(
        conversationId: conversationId,
        isCoach: isCoach,
        currentUserId: currentUserId);
  }

  @override
  void dispose() {
    _convSub?.cancel();
    _msgSub?.cancel();
    _unreadSub?.cancel();
    super.dispose();
  }
}
