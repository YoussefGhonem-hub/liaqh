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

  /// Real-time stream of messages in a conversation
  Stream<List<ChatMessage>> messagesStream(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromDoc).toList());
  }

  /// Real-time stream of all conversations for a user.
  /// No orderBy → avoids needing a composite Firestore index; the UI sorts
  /// by lastMessageAt client-side.
  Stream<List<ChatConversation>> conversationsStream(
      String userId, bool isCoach) {
    return _db
        .collection('conversations')
        .where(isCoach ? 'coachId' : 'traineeId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(ChatConversation.fromDoc).toList();
      list.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      return list;
    });
  }

  /// Mark the OTHER party's messages as read (seen) and reset unread counter.
  /// Only messages NOT sent by [currentUserId] are flagged — so a sender never
  /// marks their own message as "seen". Stamps readAt for real-time receipts.
  Future<void> markRead({
    required String conversationId,
    required bool isCoach,
    required String currentUserId,
  }) async {
    final convRef = _db.collection('conversations').doc(conversationId);
    await convRef.set(
        {isCoach ? 'unreadCoach' : 'unreadTrainee': 0},
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

  /// Real-time total unread count across all conversations for a user
  Stream<int> totalUnreadStream(String userId, bool isCoach) {
    final field = isCoach ? 'unreadCoach' : 'unreadTrainee';
    return _db
        .collection('conversations')
        .where(isCoach ? 'coachId' : 'traineeId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.fold<int>(
              0,
              (acc, doc) =>
                  acc + ((doc.data()[field] ?? 0) as int),
            ));
  }
}
