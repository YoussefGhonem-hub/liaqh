class SupportTicketModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String subject;
  final String status; // Open | Closed
  final String? lastMessage;
  final DateTime createdAt;
  final DateTime? lastMessageAt;

  SupportTicketModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.status,
    this.lastMessage,
    required this.createdAt,
    this.lastMessageAt,
  });

  bool get isOpen => status == 'Open';

  factory SupportTicketModel.fromJson(Map<String, dynamic> j) => SupportTicketModel(
        id: j['id'],
        userId: j['userId'],
        userName: j['userName'] ?? '',
        userEmail: j['userEmail'] ?? '',
        subject: j['subject'] ?? '',
        status: j['status'] ?? 'Open',
        lastMessage: j['lastMessage'],
        createdAt: DateTime.parse(j['createdAt']),
        lastMessageAt: j['lastMessageAt'] != null
            ? DateTime.parse(j['lastMessageAt'])
            : null,
      );
}

class SupportMessageModel {
  final String id;
  final String senderUserId;
  final String senderName;
  final bool isFromOwner;
  final String body;
  final DateTime createdAt;

  SupportMessageModel({
    required this.id,
    required this.senderUserId,
    required this.senderName,
    required this.isFromOwner,
    required this.body,
    required this.createdAt,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> j) => SupportMessageModel(
        id: j['id'],
        senderUserId: j['senderUserId'],
        senderName: j['senderName'] ?? '',
        isFromOwner: j['isFromOwner'] as bool? ?? false,
        body: j['body'] ?? '',
        createdAt: DateTime.parse(j['createdAt']),
      );
}

class SupportTicketDetailModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String subject;
  final String status;
  final DateTime createdAt;
  final List<SupportMessageModel> messages;

  SupportTicketDetailModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.messages,
  });

  bool get isOpen => status == 'Open';

  factory SupportTicketDetailModel.fromJson(Map<String, dynamic> j) =>
      SupportTicketDetailModel(
        id: j['id'],
        userId: j['userId'],
        userName: j['userName'] ?? '',
        userEmail: j['userEmail'] ?? '',
        subject: j['subject'] ?? '',
        status: j['status'] ?? 'Open',
        createdAt: DateTime.parse(j['createdAt']),
        messages: (j['messages'] as List? ?? [])
            .map((m) => SupportMessageModel.fromJson(m))
            .toList(),
      );
}
