class GymCoach {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final bool isActive;
  final int traineeCount;
  final int traineeLimit;
  final String? bio;
  final String? profileImageUrl;

  GymCoach({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.isActive,
    required this.traineeCount,
    required this.traineeLimit,
    this.bio,
    this.profileImageUrl,
  });

  factory GymCoach.fromJson(Map<String, dynamic> j) => GymCoach(
        id: j['id'],
        userId: j['userId'],
        fullName: j['fullName'] ?? '',
        email: j['email'] ?? '',
        isActive: j['isActive'] as bool? ?? true,
        traineeCount: j['traineeCount'] as int? ?? 0,
        traineeLimit: j['traineeLimit'] as int? ?? 30,
        bio: j['bio'],
        profileImageUrl: j['profileImageUrl'],
      );
}

class UnpaidTrainee {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String goal;
  final double currentWeightKg;
  final double heightCm;
  final String coachName;

  UnpaidTrainee({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.goal,
    required this.currentWeightKg,
    required this.heightCm,
    required this.coachName,
  });

  factory UnpaidTrainee.fromJson(Map<String, dynamic> j) => UnpaidTrainee(
        id: j['id'],
        userId: j['userId'],
        fullName: j['fullName'] ?? '',
        email: j['email'] ?? '',
        goal: j['goal'] ?? '',
        currentWeightKg: (j['currentWeightKg'] as num?)?.toDouble() ?? 0,
        heightCm: (j['heightCm'] as num?)?.toDouble() ?? 0,
        coachName: j['coachName'] ?? '',
      );
}

class GymAdminDashboard {
  final int totalCoaches;
  final int totalTrainees;
  final int activeMembers;
  final double expectedMonthlyRevenue;
  final int expiringThisWeek;
  final int newTraineesThisMonth;
  final int unpaidTrainees;

  GymAdminDashboard({
    required this.totalCoaches,
    required this.totalTrainees,
    required this.activeMembers,
    required this.expectedMonthlyRevenue,
    required this.expiringThisWeek,
    required this.newTraineesThisMonth,
    required this.unpaidTrainees,
  });

  factory GymAdminDashboard.fromJson(Map<String, dynamic> j) => GymAdminDashboard(
        totalCoaches: j['totalCoaches'] as int? ?? 0,
        totalTrainees: j['totalTrainees'] as int? ?? 0,
        activeMembers: j['activeMembers'] as int? ?? 0,
        expectedMonthlyRevenue:
            (j['expectedMonthlyRevenue'] as num?)?.toDouble() ?? 0,
        expiringThisWeek: j['expiringThisWeek'] as int? ?? 0,
        newTraineesThisMonth: j['newTraineesThisMonth'] as int? ?? 0,
        unpaidTrainees: j['unpaidTrainees'] as int? ?? 0,
      );
}
