// Models for the Platform Owner role. All fromJson are null-safe.

double _toDouble(dynamic v) => v == null ? 0.0 : (v as num).toDouble();
int _toInt(dynamic v) => v == null ? 0 : (v as num).toInt();

class MonthlyRevenuePoint {
  final String month;
  final double amount;
  MonthlyRevenuePoint({required this.month, required this.amount});

  factory MonthlyRevenuePoint.fromJson(Map<String, dynamic> j) =>
      MonthlyRevenuePoint(
        month: j['month']?.toString() ?? '',
        amount: _toDouble(j['amount']),
      );
}

class MonthlyGrowthPoint {
  final String month;
  final int newGyms;
  final int newTrainees;
  MonthlyGrowthPoint({
    required this.month,
    required this.newGyms,
    required this.newTrainees,
  });

  factory MonthlyGrowthPoint.fromJson(Map<String, dynamic> j) =>
      MonthlyGrowthPoint(
        month: j['month']?.toString() ?? '',
        newGyms: _toInt(j['newGyms']),
        newTrainees: _toInt(j['newTrainees']),
      );
}

class PlatformOverview {
  final int totalGyms;
  final int activeGyms;
  final int inactiveGyms;
  final int totalCoaches;
  final int totalTrainees;
  final int totalAdmins;
  final int totalInBodyMeasurements;
  final int totalWorkoutSessions;
  final int totalMealPlans;
  final double totalRevenue;
  final double revenueThisMonth;
  final String currency;
  final int newGymsThisMonth;
  final int newTraineesThisMonth;
  final List<MonthlyRevenuePoint> monthlyRevenue;
  final List<MonthlyGrowthPoint> monthlyGrowth;

  PlatformOverview({
    required this.totalGyms,
    required this.activeGyms,
    required this.inactiveGyms,
    required this.totalCoaches,
    required this.totalTrainees,
    required this.totalAdmins,
    required this.totalInBodyMeasurements,
    required this.totalWorkoutSessions,
    required this.totalMealPlans,
    required this.totalRevenue,
    required this.revenueThisMonth,
    required this.currency,
    required this.newGymsThisMonth,
    required this.newTraineesThisMonth,
    required this.monthlyRevenue,
    required this.monthlyGrowth,
  });

  factory PlatformOverview.fromJson(Map<String, dynamic> j) => PlatformOverview(
        totalGyms: _toInt(j['totalGyms']),
        activeGyms: _toInt(j['activeGyms']),
        inactiveGyms: _toInt(j['inactiveGyms']),
        totalCoaches: _toInt(j['totalCoaches']),
        totalTrainees: _toInt(j['totalTrainees']),
        totalAdmins: _toInt(j['totalAdmins']),
        totalInBodyMeasurements: _toInt(j['totalInBodyMeasurements']),
        totalWorkoutSessions: _toInt(j['totalWorkoutSessions']),
        totalMealPlans: _toInt(j['totalMealPlans']),
        totalRevenue: _toDouble(j['totalRevenue']),
        revenueThisMonth: _toDouble(j['revenueThisMonth']),
        currency: j['currency']?.toString() ?? '',
        newGymsThisMonth: _toInt(j['newGymsThisMonth']),
        newTraineesThisMonth: _toInt(j['newTraineesThisMonth']),
        monthlyRevenue: (j['monthlyRevenue'] as List? ?? [])
            .map((e) => MonthlyRevenuePoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        monthlyGrowth: (j['monthlyGrowth'] as List? ?? [])
            .map((e) => MonthlyGrowthPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class GymSummary {
  final String id;
  final String name;
  final String ownerEmail;
  final bool isActive;
  final bool isPersonal;
  final String currency;
  final DateTime? createdAt;
  final int coachCount;
  final int traineeCount;
  final int activeTraineeCount;
  final double totalRevenue;

  GymSummary({
    required this.id,
    required this.name,
    required this.ownerEmail,
    required this.isActive,
    required this.isPersonal,
    required this.currency,
    required this.createdAt,
    required this.coachCount,
    required this.traineeCount,
    required this.activeTraineeCount,
    required this.totalRevenue,
  });

  factory GymSummary.fromJson(Map<String, dynamic> j) => GymSummary(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        ownerEmail: j['ownerEmail']?.toString() ?? '',
        isActive: j['isActive'] == true,
        isPersonal: j['isPersonal'] == true,
        currency: j['currency']?.toString() ?? '',
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString())
            : null,
        coachCount: _toInt(j['coachCount']),
        traineeCount: _toInt(j['traineeCount']),
        activeTraineeCount: _toInt(j['activeTraineeCount']),
        totalRevenue: _toDouble(j['totalRevenue']),
      );
}

class GymCoach {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final bool isActive;
  final int traineeCount;

  GymCoach({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.isActive,
    required this.traineeCount,
  });

  factory GymCoach.fromJson(Map<String, dynamic> j) => GymCoach(
        id: j['id']?.toString() ?? '',
        userId: j['userId']?.toString() ?? '',
        fullName: j['fullName']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
        isActive: j['isActive'] == true,
        traineeCount: _toInt(j['traineeCount']),
      );
}

class GymPlan {
  final String id;
  final String name;
  final double price;
  final int durationDays;
  final bool isActive;

  GymPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.isActive,
  });

  factory GymPlan.fromJson(Map<String, dynamic> j) => GymPlan(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        price: _toDouble(j['price']),
        durationDays: _toInt(j['durationDays']),
        isActive: j['isActive'] == true,
      );
}

class GymDetail {
  final String id;
  final String name;
  final String ownerEmail;
  final bool isActive;
  final bool isPersonal;
  final String currency;
  final String timeZone;
  final String defaultLanguage;
  final String? logoUrl;
  final String? primaryColor;
  final DateTime? createdAt;
  final int coachCount;
  final int traineeCount;
  final int activeMembershipCount;
  final double totalRevenue;
  final double revenueThisMonth;
  final List<GymCoach> coaches;
  final List<GymPlan> plans;

  GymDetail({
    required this.id,
    required this.name,
    required this.ownerEmail,
    required this.isActive,
    required this.isPersonal,
    required this.currency,
    required this.timeZone,
    required this.defaultLanguage,
    required this.logoUrl,
    required this.primaryColor,
    required this.createdAt,
    required this.coachCount,
    required this.traineeCount,
    required this.activeMembershipCount,
    required this.totalRevenue,
    required this.revenueThisMonth,
    required this.coaches,
    required this.plans,
  });

  factory GymDetail.fromJson(Map<String, dynamic> j) => GymDetail(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        ownerEmail: j['ownerEmail']?.toString() ?? '',
        isActive: j['isActive'] == true,
        isPersonal: j['isPersonal'] == true,
        currency: j['currency']?.toString() ?? '',
        timeZone: j['timeZone']?.toString() ?? '',
        defaultLanguage: j['defaultLanguage']?.toString() ?? '',
        logoUrl: j['logoUrl']?.toString(),
        primaryColor: j['primaryColor']?.toString(),
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString())
            : null,
        coachCount: _toInt(j['coachCount']),
        traineeCount: _toInt(j['traineeCount']),
        activeMembershipCount: _toInt(j['activeMembershipCount']),
        totalRevenue: _toDouble(j['totalRevenue']),
        revenueThisMonth: _toDouble(j['revenueThisMonth']),
        coaches: (j['coaches'] as List? ?? [])
            .map((e) => GymCoach.fromJson(e as Map<String, dynamic>))
            .toList(),
        plans: (j['plans'] as List? ?? [])
            .map((e) => GymPlan.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class RevenueByGym {
  final String gymId;
  final String gymName;
  final double revenue;
  final int transactionCount;

  RevenueByGym({
    required this.gymId,
    required this.gymName,
    required this.revenue,
    required this.transactionCount,
  });

  factory RevenueByGym.fromJson(Map<String, dynamic> j) => RevenueByGym(
        gymId: j['gymId']?.toString() ?? '',
        gymName: j['gymName']?.toString() ?? '',
        revenue: _toDouble(j['revenue']),
        transactionCount: _toInt(j['transactionCount']),
      );
}

class RecentTransaction {
  final String id;
  final String traineeName;
  final String gymName;
  final double amount;
  final String currency;
  final String status;
  final DateTime? billedAt;

  RecentTransaction({
    required this.id,
    required this.traineeName,
    required this.gymName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.billedAt,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> j) =>
      RecentTransaction(
        id: j['id']?.toString() ?? '',
        traineeName: j['traineeName']?.toString() ?? '',
        gymName: j['gymName']?.toString() ?? '',
        amount: _toDouble(j['amount']),
        currency: j['currency']?.toString() ?? '',
        status: j['status']?.toString() ?? '',
        billedAt: j['billedAt'] != null
            ? DateTime.tryParse(j['billedAt'].toString())
            : null,
      );
}

class PlatformRevenue {
  final double totalRevenue;
  final double revenueThisMonth;
  final String currency;
  final int totalTransactions;
  final List<RevenueByGym> byGym;
  final List<MonthlyRevenuePoint> monthly;
  final List<RecentTransaction> recentTransactions;

  PlatformRevenue({
    required this.totalRevenue,
    required this.revenueThisMonth,
    required this.currency,
    required this.totalTransactions,
    required this.byGym,
    required this.monthly,
    required this.recentTransactions,
  });

  factory PlatformRevenue.fromJson(Map<String, dynamic> j) => PlatformRevenue(
        totalRevenue: _toDouble(j['totalRevenue']),
        revenueThisMonth: _toDouble(j['revenueThisMonth']),
        currency: j['currency']?.toString() ?? '',
        totalTransactions: _toInt(j['totalTransactions']),
        byGym: (j['byGym'] as List? ?? [])
            .map((e) => RevenueByGym.fromJson(e as Map<String, dynamic>))
            .toList(),
        monthly: (j['monthly'] as List? ?? [])
            .map((e) => MonthlyRevenuePoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        recentTransactions: (j['recentTransactions'] as List? ?? [])
            .map((e) => RecentTransaction.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PlatformUser {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String gymId;
  final String gymName;
  final bool isActive;
  final DateTime? createdAt;

  PlatformUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.gymId,
    required this.gymName,
    required this.isActive,
    required this.createdAt,
  });

  factory PlatformUser.fromJson(Map<String, dynamic> j) => PlatformUser(
        id: j['id']?.toString() ?? '',
        fullName: j['fullName']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
        role: j['role']?.toString() ?? '',
        gymId: j['gymId']?.toString() ?? '',
        gymName: j['gymName']?.toString() ?? '',
        isActive: j['isActive'] == true,
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString())
            : null,
      );
}

class UserDetail {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String gymId;
  final String gymName;
  final bool isActive;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String preferredLanguage;
  final DateTime? createdAt;
  // Coach-specific
  final int? coachTraineeCount;
  final int? coachTraineeLimit;
  final String? coachBio;
  // Trainee-specific
  final String? traineeCoachName;
  final String? traineeGoal;
  final double? traineeHeightCm;
  final double? traineeCurrentWeightKg;
  final String? traineeMembershipStatus;
  final DateTime? traineeMembershipEnd;

  UserDetail({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.gymId,
    required this.gymName,
    required this.isActive,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.preferredLanguage,
    required this.createdAt,
    required this.coachTraineeCount,
    required this.coachTraineeLimit,
    required this.coachBio,
    required this.traineeCoachName,
    required this.traineeGoal,
    required this.traineeHeightCm,
    required this.traineeCurrentWeightKg,
    required this.traineeMembershipStatus,
    required this.traineeMembershipEnd,
  });

  factory UserDetail.fromJson(Map<String, dynamic> j) => UserDetail(
        id: j['id']?.toString() ?? '',
        fullName: j['fullName']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
        role: j['role']?.toString() ?? '',
        gymId: j['gymId']?.toString() ?? '',
        gymName: j['gymName']?.toString() ?? '',
        isActive: j['isActive'] == true,
        phoneNumber: j['phoneNumber']?.toString(),
        profileImageUrl: j['profileImageUrl']?.toString(),
        preferredLanguage: j['preferredLanguage']?.toString() ?? '',
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString())
            : null,
        coachTraineeCount: (j['coachTraineeCount'] as num?)?.toInt(),
        coachTraineeLimit: (j['coachTraineeLimit'] as num?)?.toInt(),
        coachBio: j['coachBio']?.toString(),
        traineeCoachName: j['traineeCoachName']?.toString(),
        traineeGoal: j['traineeGoal']?.toString(),
        traineeHeightCm: (j['traineeHeightCm'] as num?)?.toDouble(),
        traineeCurrentWeightKg:
            (j['traineeCurrentWeightKg'] as num?)?.toDouble(),
        traineeMembershipStatus: j['traineeMembershipStatus']?.toString(),
        traineeMembershipEnd: j['traineeMembershipEnd'] != null
            ? DateTime.tryParse(j['traineeMembershipEnd'].toString())
            : null,
      );
}

class PlatformPlan {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int durationDays;
  final String billingCycle;
  final bool isActive;

  PlatformPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.billingCycle,
    required this.isActive,
  });

  factory PlatformPlan.fromJson(Map<String, dynamic> j) => PlatformPlan(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        description: j['description']?.toString(),
        price: _toDouble(j['price']),
        durationDays: _toInt(j['durationDays']),
        billingCycle: j['billingCycle']?.toString() ?? '',
        isActive: j['isActive'] == true,
      );
}

class PaginatedUsers {
  final List<PlatformUser> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  PaginatedUsers({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginatedUsers.fromJson(Map<String, dynamic> j) => PaginatedUsers(
        items: (j['items'] as List? ?? [])
            .map((e) => PlatformUser.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCount: _toInt(j['totalCount']),
        pageNumber: _toInt(j['pageNumber']),
        pageSize: _toInt(j['pageSize']),
        totalPages: _toInt(j['totalPages']),
      );
}

class PlatformCoach {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String gymId;
  final String gymName;
  final bool isActive;
  final int traineeCount;
  final int traineeLimit;
  final String? bio;

  PlatformCoach({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.gymId,
    required this.gymName,
    required this.isActive,
    required this.traineeCount,
    required this.traineeLimit,
    required this.bio,
  });

  factory PlatformCoach.fromJson(Map<String, dynamic> j) => PlatformCoach(
        id: j['id']?.toString() ?? '',
        userId: j['userId']?.toString() ?? '',
        fullName: j['fullName']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
        gymId: j['gymId']?.toString() ?? '',
        gymName: j['gymName']?.toString() ?? '',
        isActive: j['isActive'] == true,
        traineeCount: _toInt(j['traineeCount']),
        traineeLimit: _toInt(j['traineeLimit']),
        bio: j['bio']?.toString(),
      );
}
