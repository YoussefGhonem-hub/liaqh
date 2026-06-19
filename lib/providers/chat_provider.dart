import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/chat_models.dart';
import '../data/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final _service = ChatService();

  static const _msgPageSize = 30;

  List<ChatConversation> _conversations = [];
  List<ChatMessage> _messages = [];
  int _totalUnread = 0;
  bool _loading = false;

  int _msgLimit = _msgPageSize;
  bool _messagesHasMore = false;
  String? _currentConvId;

  List<ChatConversation> get conversations => _conversations;
  List<ChatMessage> get messages => _messages;
  bool get messagesHasMore => _messagesHasMore;
  int get totalUnread => _totalUnread;
  bool get loading => _loading;

  StreamSubscription<List<ChatConversation>>? _convSub;
  StreamSubscription<List<ChatMessage>>? _msgSub;
  StreamSubscription<int>? _unreadSub;

  // ── Start listening to all conversations for the logged-in user ──────────
  void listenConversations(String userId, [bool _ = false]) {
    _convSub?.cancel();
    _unreadSub?.cancel();

    _convSub = _service.conversationsStream(userId).listen(
      (list) {
        _conversations = list;
        notifyListeners();
      },
      onError: (e) => debugPrint('conversationsStream error: $e'),
    );

    _unreadSub = _service.totalUnreadStream(userId).listen(
      (count) {
        _totalUnread = count;
        notifyListeners();
      },
      onError: (e) => debugPrint('totalUnreadStream error: $e'),
    );
  }

  bool _otherTyping = false;
  bool get otherTyping => _otherTyping;
  StreamSubscription<bool>? _typingSub;

  /// Listen to the other party's typing status for the open conversation.
  void listenTyping(String conversationId, bool isCoachSlot) {
    _typingSub?.cancel();
    _typingSub = _service.typingStream(conversationId, isCoachSlot).listen((t) {
      if (t != _otherTyping) {
        _otherTyping = t;
        notifyListeners();
      }
    }, onError: (_) {});
  }

  void stopTyping(String conversationId, bool isCoachSlot) {
    _typingSub?.cancel();
    _otherTyping = false;
    _service.setTyping(conversationId, isCoachSlot, false);
  }

  /// Report the current user's typing state (called from the input field).
  void setTyping(String conversationId, bool isCoachSlot, bool isTyping) {
    _service.setTyping(conversationId, isCoachSlot, isTyping);
  }

  // ── Start listening to messages in one conversation (windowed) ───────────
  void listenMessages(String conversationId, {bool reset = true}) {
    if (reset) _msgLimit = _msgPageSize;
    _currentConvId = conversationId;
    _msgSub?.cancel();
    _msgSub = _service.messagesStream(conversationId, limit: _msgLimit).listen(
      (list) {
        // If the window is full, there are likely older messages to fetch.
        _messagesHasMore = list.length >= _msgLimit;
        _messages = list;
        notifyListeners();
      },
      onError: (e) => debugPrint('messagesStream error: $e'),
    );
  }

  /// Grows the message window to load older messages.
  void loadMoreMessages() {
    if (!_messagesHasMore || _currentConvId == null) return;
    _msgLimit += _msgPageSize;
    listenMessages(_currentConvId!, reset: false);
  }

  void clearMessages() {
    _msgSub?.cancel();
    _messages = [];
    _msgLimit = _msgPageSize;
    _messagesHasMore = false;
    _currentConvId = null;
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
    String? replyToId,
    String? replyToText,
    String? replyToSender,
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
      replyToId: replyToId,
      replyToText: replyToText,
      replyToSender: replyToSender,
    );
  }

  /// Add/replace/remove an emoji reaction on a message.
  Future<void> reactToMessage(
      String conversationId, String messageId, String userId, String emoji) {
    return _service.setReaction(
      conversationId: conversationId,
      messageId: messageId,
      userId: userId,
      emoji: emoji,
    );
  }

  /// Edit a message's text (sender only — enforced in the UI).
  Future<void> editMessage(
      String conversationId, String messageId, String newText) async {
    if (newText.trim().isEmpty) return;
    await _service.editMessage(
      conversationId: conversationId,
      messageId: messageId,
      newText: newText.trim(),
    );
  }

  /// Delete a message (sender only — enforced in the UI).
  Future<void> deleteMessage(String conversationId, String messageId) async {
    await _service.deleteMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  // ── Mark conversation as read ────────────────────────────────────────────
  Future<void> markRead(
      String conversationId, bool isCoachSlot, String currentUserId) async {
    await _service.markRead(
        conversationId: conversationId,
        isCoachSlot: isCoachSlot,
        currentUserId: currentUserId);
  }

  @override
  void dispose() {
    _convSub?.cancel();
    _msgSub?.cancel();
    _unreadSub?.cancel();
    _typingSub?.cancel();
    super.dispose();
  }
}
