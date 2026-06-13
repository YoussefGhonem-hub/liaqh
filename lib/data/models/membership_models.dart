class MembershipPlanModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int durationDays;
  final String billingCycle;
  final bool isFree;

  MembershipPlanModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.durationDays,
    required this.billingCycle,
    this.isFree = false,
  });

  factory MembershipPlanModel.fromJson(Map<String, dynamic> j) => MembershipPlanModel(
        id: j['id'],
        name: j['name'],
        description: j['description'],
        price: (j['price'] as num).toDouble(),
        durationDays: j['durationDays'] as int,
        billingCycle: j['billingCycle'] ?? 'Monthly',
        isFree: j['isFree'] as bool? ?? false,
      );
}

class TraineeMembershipModel {
  final String id;
  final String planName;
  final double price;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // Pending | Active | Expired | Cancelled | Frozen
  final bool autoRenew;
  final bool isExpiring;
  final String billingCycle;

  TraineeMembershipModel({
    required this.id,
    required this.planName,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.autoRenew,
    required this.isExpiring,
    required this.billingCycle,
  });

  factory TraineeMembershipModel.fromJson(Map<String, dynamic> j) => TraineeMembershipModel(
        id: j['id'],
        planName: j['planName'],
        price: (j['price'] as num).toDouble(),
        startDate: DateTime.parse(j['startDate']),
        endDate: DateTime.parse(j['endDate']),
        status: j['status'],
        autoRenew: j['autoRenew'] as bool,
        isExpiring: j['isExpiring'] as bool,
        billingCycle: j['billingCycle'] ?? 'Monthly',
      );

  bool get isActive => status == 'Active';
}

/// A single payable period of a coach-managed membership (cash collection).
class MembershipPaymentModel {
  final String id;
  final int sequenceNumber;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double amount;
  final String status; // Paid | Unpaid
  final DateTime? paidAt;
  final bool isCurrent;

  MembershipPaymentModel({
    required this.id,
    required this.sequenceNumber,
    required this.periodStart,
    required this.periodEnd,
    required this.amount,
    required this.status,
    required this.paidAt,
    required this.isCurrent,
  });

  bool get isPaid => status == 'Paid';
  bool get isFree => status == 'Free';
  bool get hasAccess => status == 'Paid' || status == 'Free';

  factory MembershipPaymentModel.fromJson(Map<String, dynamic> j) => MembershipPaymentModel(
        id: j['id'],
        sequenceNumber: j['sequenceNumber'] as int,
        periodStart: DateTime.parse(j['periodStart']),
        periodEnd: DateTime.parse(j['periodEnd']),
        amount: (j['amount'] as num).toDouble(),
        status: j['status'],
        paidAt: j['paidAt'] != null ? DateTime.parse(j['paidAt']) : null,
        isCurrent: j['isCurrent'] as bool? ?? false,
      );
}

class GymRevenueModel {
  final int activeMembers;
  final double expectedMonthlyRevenue;
  final int expiringThisWeek;

  GymRevenueModel({
    required this.activeMembers,
    required this.expectedMonthlyRevenue,
    required this.expiringThisWeek,
  });

  factory GymRevenueModel.fromJson(Map<String, dynamic> j) => GymRevenueModel(
        activeMembers: j['activeMembers'] as int,
        expectedMonthlyRevenue: (j['expectedMonthlyRevenue'] as num).toDouble(),
        expiringThisWeek: j['expiringThisWeek'] as int,
      );
}

class TraineeDetailModel {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String goal;
  final double heightCm;
  final double currentWeightKg;
  final String? dietaryRestrictions;
  final String? medicalNotes;
  final String? profileImageUrl;
  final int? age;
  final double? latestBodyScore;
  final DateTime createdAt;

  TraineeDetailModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.goal,
    required this.heightCm,
    required this.currentWeightKg,
    this.dietaryRestrictions,
    this.medicalNotes,
    this.profileImageUrl,
    this.age,
    this.latestBodyScore,
    required this.createdAt,
  });

  factory TraineeDetailModel.fromJson(Map<String, dynamic> j) => TraineeDetailModel(
        id: j['id'],
        userId: j['userId'],
        fullName: j['fullName'],
        email: j['email'],
        phoneNumber: j['phoneNumber'],
        goal: j['goal'],
        heightCm: (j['heightCm'] as num).toDouble(),
        currentWeightKg: (j['currentWeightKg'] as num).toDouble(),
        dietaryRestrictions: j['dietaryRestrictions'],
        medicalNotes: j['medicalNotes'],
        profileImageUrl: j['profileImageUrl'],
        age: j['age'],
        latestBodyScore: j['latestBodyScore'] != null ? (j['latestBodyScore'] as num).toDouble() : null,
        createdAt: DateTime.parse(j['createdAt']),
      );
}
