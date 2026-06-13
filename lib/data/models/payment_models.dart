class SubscriptionAccess {
  final bool isPaymentRequired;
  final bool hasActiveSubscription; // true only when BOTH below are paid
  final bool paidPlatform; // Type 1 — paid to the platform
  final bool paidCoach; // Type 2 — coach marked the cash period Paid/Free

  SubscriptionAccess({
    required this.isPaymentRequired,
    required this.hasActiveSubscription,
    this.paidPlatform = false,
    this.paidCoach = false,
  });

  /// Premium content (workouts, nutrition, inbody, progress) is locked when
  /// payment is required and the trainee hasn't completed BOTH payments. Basic
  /// pages (dashboard, profile, settings…) stay accessible.
  bool get premiumLocked => isPaymentRequired && !hasActiveSubscription;

  /// Kept for compatibility — same meaning as [premiumLocked].
  bool get mustSubscribe => premiumLocked;

  factory SubscriptionAccess.fromJson(Map<String, dynamic> j) => SubscriptionAccess(
        isPaymentRequired: j['isPaymentRequired'] as bool? ?? false,
        hasActiveSubscription: j['hasActiveSubscription'] as bool? ?? false,
        paidPlatform: j['paidPlatform'] as bool? ?? false,
        paidCoach: j['paidCoach'] as bool? ?? false,
      );
}

class MySubscription {
  final bool hasActiveMembership;
  final String status;
  final String? planName;
  final double? price;
  final String currency;
  final String? billingCycle;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? daysRemaining;
  final bool autoRenew;
  final bool isRecurring;
  final DateTime? nextBillDate;
  final String? paddleSubscriptionId;
  final List<MySubTxn> recentPayments;

  MySubscription({
    required this.hasActiveMembership,
    required this.status,
    this.planName,
    this.price,
    required this.currency,
    this.billingCycle,
    this.startDate,
    this.endDate,
    this.daysRemaining,
    required this.autoRenew,
    required this.isRecurring,
    this.nextBillDate,
    this.paddleSubscriptionId,
    required this.recentPayments,
  });

  factory MySubscription.fromJson(Map<String, dynamic> j) => MySubscription(
        hasActiveMembership: j['hasActiveMembership'] as bool? ?? false,
        status: j['status'] as String? ?? 'None',
        planName: j['planName'],
        price: j['price'] != null ? (j['price'] as num).toDouble() : null,
        currency: j['currency'] as String? ?? 'EGP',
        billingCycle: j['billingCycle'],
        startDate: j['startDate'] != null ? DateTime.parse(j['startDate']) : null,
        endDate: j['endDate'] != null ? DateTime.parse(j['endDate']) : null,
        daysRemaining:
            j['daysRemaining'] != null ? (j['daysRemaining'] as num).toInt() : null,
        autoRenew: j['autoRenew'] as bool? ?? false,
        isRecurring: j['isRecurring'] as bool? ?? false,
        nextBillDate:
            j['nextBillDate'] != null ? DateTime.parse(j['nextBillDate']) : null,
        paddleSubscriptionId: j['paddleSubscriptionId'],
        recentPayments: ((j['recentPayments'] as List<dynamic>?) ?? [])
            .map((e) => MySubTxn.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class MySubTxn {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final DateTime? billedAt;
  final String? cardLast4;

  MySubTxn({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    this.billedAt,
    this.cardLast4,
  });

  factory MySubTxn.fromJson(Map<String, dynamic> j) => MySubTxn(
        id: j['id'] as String,
        amount: (j['amount'] as num).toDouble(),
        currency: j['currency'] as String? ?? 'EGP',
        status: j['status'] as String? ?? '',
        billedAt: j['billedAt'] != null ? DateTime.parse(j['billedAt']) : null,
        cardLast4: j['cardLast4'],
      );
}

class CheckoutResult {
  final String sessionId;
  final String checkoutUrl;
  final String transactionId;

  CheckoutResult({
    required this.sessionId,
    required this.checkoutUrl,
    required this.transactionId,
  });

  factory CheckoutResult.fromJson(Map<String, dynamic> j) => CheckoutResult(
        sessionId: j['sessionId'] as String,
        checkoutUrl: j['checkoutUrl'] as String,
        transactionId: j['transactionId'] as String,
      );
}

class CheckoutStatus {
  final String sessionId;
  final String status; // initiated | completed | cancelled | failed
  final String? paddleTransactionId;

  CheckoutStatus({
    required this.sessionId,
    required this.status,
    this.paddleTransactionId,
  });

  factory CheckoutStatus.fromJson(Map<String, dynamic> j) => CheckoutStatus(
        sessionId: j['sessionId'] as String,
        status: j['status'] as String,
        paddleTransactionId: j['paddleTransactionId'] as String?,
      );
}

class PaymentSubscription {
  final String id;
  final String paddleSubscriptionId;
  final String status;
  final String currency;
  final double unitPrice;
  final DateTime? currentPeriodEnd;
  final DateTime? nextBillDate;
  final DateTime? cancelledAt;
  final String paddlePriceId;
  final List<TransactionSummary> recentTransactions;

  PaymentSubscription({
    required this.id,
    required this.paddleSubscriptionId,
    required this.status,
    required this.currency,
    required this.unitPrice,
    this.currentPeriodEnd,
    this.nextBillDate,
    this.cancelledAt,
    required this.paddlePriceId,
    required this.recentTransactions,
  });

  bool get isActive => status == 'active';
  bool get isCancelled => status == 'cancelled' || status == 'cancellation_scheduled';

  factory PaymentSubscription.fromJson(Map<String, dynamic> j) => PaymentSubscription(
        id: j['id'] as String,
        paddleSubscriptionId: j['paddleSubscriptionId'] as String,
        status: j['status'] as String,
        currency: j['currency'] as String? ?? 'USD',
        unitPrice: (j['unitPrice'] as num).toDouble(),
        currentPeriodEnd: j['currentPeriodEnd'] != null ? DateTime.parse(j['currentPeriodEnd']) : null,
        nextBillDate: j['nextBillDate'] != null ? DateTime.parse(j['nextBillDate']) : null,
        cancelledAt: j['cancelledAt'] != null ? DateTime.parse(j['cancelledAt']) : null,
        paddlePriceId: j['paddlePriceId'] as String,
        recentTransactions: (j['recentTransactions'] as List<dynamic>)
            .map((e) => TransactionSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TransactionSummary {
  final String id;
  final String paddleTransactionId;
  final String status;
  final double total;
  final String currency;
  final String? paymentMethod;
  final String? cardLast4;
  final DateTime? billedAt;

  TransactionSummary({
    required this.id,
    required this.paddleTransactionId,
    required this.status,
    required this.total,
    required this.currency,
    this.paymentMethod,
    this.cardLast4,
    this.billedAt,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> j) => TransactionSummary(
        id: j['id'] as String,
        paddleTransactionId: j['paddleTransactionId'] as String,
        status: j['status'] as String,
        total: (j['total'] as num).toDouble(),
        currency: j['currency'] as String? ?? 'USD',
        paymentMethod: j['paymentMethod'] as String?,
        cardLast4: j['cardLast4'] as String?,
        billedAt: j['billedAt'] != null ? DateTime.parse(j['billedAt']) : null,
      );
}
