import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_models.dart';
import 'notification_service.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;

  /// Conversation ID is always {coachId}_{traineeId}
  static String convId(String coachId, String traineeId) =>
      '${coachId}_$traineeId';

  /// Ensure a conversation document exists (idempotent)
  Future<void> ensureConversation({
    required String coachId,
    required String traineeId,
    required String coachName,
    required String traineeName,
    required String gymId,
  }) async {
    final id = convId(coachId, traineeId);
    final ref = _db.collection('conversations').doc(id);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'coachId': coachId,
        'traineeId': traineeId,
        'coachName': coachName,
        'traineeName': traineeName,
        'gymId': gymId,
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCoach': 0,
        'unreadTrainee': 0,
      });
    }
  }

  /// Send a message and update conversation metadata atomically.
  /// Also writes an in-app notification document for the recipient.
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
    final batch = _db.batch();
    final convRef = _db.collection('conversations').doc(conversationId);
    final msgRef = convRef.collection('messages').doc();

    batch.set(msgRef, {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
      'isRead': false,
      if (contextType != null) 'contextType': contextType,
      if (contextId != null) 'contextId': contextId,
      if (contextLabel != null) 'contextLabel': contextLabel,
      if (replyToId != null) 'replyToId': replyToId,
      if (replyToText != null) 'replyToText': replyToText,
      if (replyToSender != null) 'replyToSender': replyToSender,
    });

    final unreadField = senderIsCoach ? 'unreadTrainee' : 'unreadCoach';
    final coachId = senderIsCoach ? senderId : recipientId;
    final traineeId = senderIsCoach ? recipientId : senderId;

    // Upsert (merge) so the conversation is created/queryable even if the
    // initial ensureConversation() write didn't persist. Identity fields are
    // required for the conversation to appear in both users' lists.
    batch.set(
      convRef,
      {
        'coachId': coachId,
        'traineeId': traineeId,
        if (senderIsCoach) 'coachName': senderName else 'traineeName': senderName,
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        unreadField: FieldValue.increment(1),
      },
      SetOptions(merge: true),
    );

    await batch.commit();

    // Write in-app notification for the recipient
    await NotificationService.sendInAppNotification(
      recipientId: recipientId,
      title: senderName,
      body: text,
      type: 'chat',
      conversationId: conversationId,
      senderId: senderId,
    );
  }

  /// Toggles a user's emoji reaction on a message. Passing the same emoji the
  /// user already set removes it; a different emoji replaces it.
  Future<void> setReaction({
    required String conversationId,
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    final ref = _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);
    final snap = await ref.get();
    final current =
        (snap.data()?['reactions'] as Map?)?[userId]?.toString();
    if (current == emoji) {
      await ref.update({'reactions.$userId': FieldValue.delete()});
    } else {
      await ref.update({'reactions.$userId': emoji});
    }
  }

  /// Edits a message's text. Also refreshes the conversation's lastMessage when
  /// the edited message is the latest one.
  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String newText,
  }) async {
    final convRef = _db.collection('conversations').doc(conversationId);
    await convRef.collection('messages').doc(messageId).update({
      'text': newText,
      'isEdited': true,
    });

    // If this was the most recent message, update the conversation preview.
    final latest = await convRef
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(1)
        .get();
    if (latest.docs.isNotEmpty && latest.docs.first.id == messageId) {
      await convRef.update({'lastMessage': newText});
    }
  }

  /// Deletes a message. Refreshes the conversation's lastMessage preview to the
  /// new most-recent message (or empty).
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    final convRef = _db.collection('conversations').doc(conversationId);
    await convRef.collection('messages').doc(messageId).delete();

    final latest = await convRef
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(1)
        .get();
    await convRef.update({
      'lastMessage':
          latest.docs.isNotEmpty ? (latest.docs.first.data()['text'] ?? '') : '',
    });
  }

  /// Sets the current user's typing flag (by slot) on the conversation doc.
  Future<void> setTyping(
      String conversationId, bool isCoachSlot, bool isTyping) async {
    final field = isCoachSlot ? 'typingCoachAt' : 'typingTraineeAt';
    await _db.collection('conversations').doc(conversationId).set(
      {field: isTyping ? FieldValue.serverTimestamp() : null},
      SetOptions(merge: true),
    );
  }

  /// Streams whether the OTHER party is currently typing (active within ~6s).
  Stream<bool> typingStream(String conversationId, bool isCoachSlot) {
    // The current user is [isCoachSlot]; watch the other slot's field.
    final field = isCoachSlot ? 'typingTraineeAt' : 'typingCoachAt';
    return _db
        .collection('conversations')
        .doc(conversationId)
        .snapshots()
        .map((snap) {
      final ts = snap.data()?[field];
      if (ts is! Timestamp) return false;
      return DateTime.now().difference(ts.toDate()).inSeconds.abs() <= 6;
    });
  }

  /// Real-time stream of the most recent [limit] messages in a conversation,
  /// returned in ascending (oldest→newest) order for display. Increasing
  /// [limit] loads older messages (server-side window).
  Stream<List<ChatMessage>> messagesStream(String conversationId,
      {int limit = 30}) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ChatMessage.fromDoc).toList().reversed.toList());
  }

  /// Real-time stream of all conversations for a user.
  /// No orderBy → avoids needing a composite Firestore index; the UI sorts
  /// by lastMessageAt client-side.
  /// A user's conversations — matched by identity (either slot), so it works
  /// for coaches, trainees, gym admins and the platform owner alike.
  Stream<List<ChatConversation>> conversationsStream(String userId) {
    return _db
        .collection('conversations')
        .where(Filter.or(
          Filter('coachId', isEqualTo: userId),
          Filter('traineeId', isEqualTo: userId),
        ))
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(ChatConversation.fromDoc).toList();
      list.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      return list;
    });
  }

  /// Mark the OTHER party's messages as read (seen) and reset unread counter.
  /// [isCoachSlot] = whether the current user occupies the conversation's coach
  /// slot (by identity, not global role) — so it's correct for any user pair.
  Future<void> markRead({
    required String conversationId,
    required bool isCoachSlot,
    required String currentUserId,
  }) async {
    final convRef = _db.collection('conversations').doc(conversationId);
    await convRef.set(
        {isCoachSlot ? 'unreadCoach' : 'unreadTrainee': 0},
        SetOptions(merge: true));

    final unread = await convRef
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();

    // Only mark messages from the other person as read.
    final toMark = unread.docs
        .where((doc) => (doc.data()['senderId'] ?? '') != currentUserId)
        .toList();

    if (toMark.isEmpty) return;
    final batch = _db.batch();
    for (final doc in toMark) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Real-time total unread count across all conversations for a user.
  /// Reads the correct unread counter per conversation based on which slot the
  /// user occupies (coach vs trainee), matched by identity.
  Stream<int> totalUnreadStream(String userId) {
    return _db
        .collection('conversations')
        .where(Filter.or(
          Filter('coachId', isEqualTo: userId),
          Filter('traineeId', isEqualTo: userId),
        ))
        .snapshots()
        .map((snap) => snap.docs.fold<int>(0, (acc, doc) {
              final d = doc.data();
              final isCoachSlot = (d['coachId'] ?? '') == userId;
              final field = isCoachSlot ? 'unreadCoach' : 'unreadTrainee';
              return acc + ((d[field] ?? 0) as int);
            }));
  }
}
