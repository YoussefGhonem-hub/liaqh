class PaymentMethodModel {
  final String id;
  final String code; // Paddle | InstaPay | Wallet
  final String name;
  final bool isActive;
  final bool isManual;
  final String? receiverNumber;
  final String? instructions;
  final int displayOrder;

  PaymentMethodModel({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    required this.isManual,
    this.receiverNumber,
    this.instructions,
    this.displayOrder = 0,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> j) => PaymentMethodModel(
        id: j['id'],
        code: j['code'],
        name: j['name'],
        isActive: j['isActive'] as bool,
        isManual: j['isManual'] as bool,
        receiverNumber: j['receiverNumber'],
        instructions: j['instructions'],
        displayOrder: j['displayOrder'] as int? ?? 0,
      );
}

class ManualPaymentModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String methodCode;
  final String fullAccountName;
  final String accountIdentifier;
  final String? referenceNumber;
  final double amount;
  final String status; // Pending | Accepted | Rejected
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewNote;

  ManualPaymentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.methodCode,
    required this.fullAccountName,
    required this.accountIdentifier,
    this.referenceNumber,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.reviewNote,
  });

  bool get isPending => status == 'Pending';

  factory ManualPaymentModel.fromJson(Map<String, dynamic> j) => ManualPaymentModel(
        id: j['id'],
        userId: j['userId'],
        userName: j['userName'] ?? '',
        userEmail: j['userEmail'] ?? '',
        methodCode: j['methodCode'],
        fullAccountName: j['fullAccountName'] ?? '',
        accountIdentifier: j['accountIdentifier'] ?? '',
        referenceNumber: j['referenceNumber'],
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        status: j['status'] ?? 'Pending',
        createdAt: DateTime.parse(j['createdAt']),
        reviewedAt: j['reviewedAt'] != null ? DateTime.parse(j['reviewedAt']) : null,
        reviewNote: j['reviewNote'],
      );
}
