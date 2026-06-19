import 'package:cloud_firestore/cloud_firestore.dart';

/// Kinds of entity a chat message can reference for context.
class ChatContextType {
  static const inbody = 'inbody';
  static const workout = 'workout';
  static const mealplan = 'mealplan';
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final bool isRead;
  final bool isEdited;

  /// Optional reference tying this message to a specific InBody result,
  /// workout, or meal plan so questions/adjustments have context.
  final String? contextType; // ChatContextType.*
  final String? contextId; // id of the referenced entity (nullable)
  final String? contextLabel; // human-readable label shown in the bubble

  /// Reply (quote) of another message in the same conversation.
  final String? replyToId;
  final String? replyToText;
  final String? replyToSender;

  /// Emoji reactions, keyed by reacting userId → emoji.
  final Map<String, String> reactions;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
    required this.isRead,
    this.isEdited = false,
    this.contextType,
    this.contextId,
    this.contextLabel,
    this.replyToId,
    this.replyToText,
    this.replyToSender,
    this.reactions = const {},
  });

  bool get hasContext => contextType != null && contextType!.isNotEmpty;
  bool get hasReply => replyToId != null && replyToId!.isNotEmpty;

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: d['senderId'] ?? '',
      senderName: d['senderName'] ?? '',
      text: d['text'] ?? '',
      sentAt: (d['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: d['isRead'] ?? false,
      isEdited: d['isEdited'] ?? false,
      contextType: d['contextType'],
      contextId: d['contextId'],
      contextLabel: d['contextLabel'],
      replyToId: d['replyToId'],
      replyToText: d['replyToText'],
      replyToSender: d['replyToSender'],
      reactions: (d['reactions'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v.toString())) ??
          const {},
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'sentAt': Timestamp.fromDate(sentAt),
        'isRead': isRead,
        'isEdited': isEdited,
        if (contextType != null) 'contextType': contextType,
        if (contextId != null) 'contextId': contextId,
        if (contextLabel != null) 'contextLabel': contextLabel,
        if (replyToId != null) 'replyToId': replyToId,
        if (replyToText != null) 'replyToText': replyToText,
        if (replyToSender != null) 'replyToSender': replyToSender,
        'reactions': reactions,
      };
}

class ChatConversation {
  final String id;
  final String coachId;
  final String traineeId;
  final String coachName;
  final String traineeName;
  final String gymId;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCoach;
  final int unreadTrainee;

  const ChatConversation({
    required this.id,
    required this.coachId,
    required this.traineeId,
    required this.coachName,
    required this.traineeName,
    required this.gymId,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCoach,
    required this.unreadTrainee,
  });

  factory ChatConversation.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatConversation(
      id: doc.id,
      coachId: d['coachId'] ?? '',
      traineeId: d['traineeId'] ?? '',
      coachName: d['coachName'] ?? '',
      traineeName: d['traineeName'] ?? '',
      gymId: d['gymId'] ?? '',
      lastMessage: d['lastMessage'] ?? '',
      lastMessageAt:
          (d['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCoach: (d['unreadCoach'] ?? 0) as int,
      unreadTrainee: (d['unreadTrainee'] ?? 0) as int,
    );
  }

  int unreadFor(String userId) =>
      userId == coachId ? unreadCoach : unreadTrainee;

  String otherName(String userId) =>
      userId == coachId ? traineeName : coachName;
}
