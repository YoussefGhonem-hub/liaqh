class CoachDashboard {
  final int totalTrainees;
  final int onTrack;
  final int atRisk;
  final int offTrack;
  final int activeTrainees;
  final int retentionRate;
  final int newThisMonth;
  final double revenueThisMonth;
  final int workoutsThisWeek;
  final List<TraineeStatus> trainees;

  CoachDashboard({
    required this.totalTrainees,
    required this.onTrack,
    required this.atRisk,
    required this.offTrack,
    this.activeTrainees = 0,
    this.retentionRate = 0,
    this.newThisMonth = 0,
    this.revenueThisMonth = 0,
    this.workoutsThisWeek = 0,
    required this.trainees,
  });

  factory CoachDashboard.fromJson(Map<String, dynamic> j) => CoachDashboard(
        totalTrainees: j['totalTrainees'] ?? 0,
        onTrack: j['onTrack'] ?? 0,
        atRisk: j['atRisk'] ?? 0,
        offTrack: j['offTrack'] ?? 0,
        activeTrainees: j['activeTrainees'] ?? 0,
        retentionRate: j['retentionRate'] ?? 0,
        newThisMonth: j['newThisMonth'] ?? 0,
        revenueThisMonth: (j['revenueThisMonth'] as num?)?.toDouble() ?? 0,
        workoutsThisWeek: j['workoutsThisWeek'] ?? 0,
        trainees: (j['trainees'] as List? ?? [])
            .map((t) => TraineeStatus.fromJson(t))
            .toList(),
      );
}

class TraineeStatus {
  final String traineeId;
  final String fullName;
  final String goal;
  final String adherenceStatus;
  final double? latestBodyScore;
  final bool membershipExpiringSoon;

  TraineeStatus({
    required this.traineeId,
    required this.fullName,
    required this.goal,
    required this.adherenceStatus,
    this.latestBodyScore,
    required this.membershipExpiringSoon,
  });

  factory TraineeStatus.fromJson(Map<String, dynamic> j) => TraineeStatus(
        traineeId: j['traineeId'],
        fullName: j['fullName'],
        goal: j['goal'],
        adherenceStatus: j['adherenceStatus'],
        latestBodyScore: j['latestBodyScore'] != null
            ? (j['latestBodyScore'] as num).toDouble()
            : null,
        membershipExpiringSoon: j['membershipExpiringSoon'] ?? false,
      );
}

class LeaderboardEntry {
  final int rank;
  final String traineeId;
  final String fullName;
  final int points;
  final int streak;
  final String? profileImageUrl;

  LeaderboardEntry({
    required this.rank,
    required this.traineeId,
    required this.fullName,
    required this.points,
    required this.streak,
    this.profileImageUrl,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) => LeaderboardEntry(
        rank: j['rank'],
        traineeId: j['traineeId'],
        fullName: j['fullName'],
        points: j['points'],
        streak: j['streak'],
        profileImageUrl: j['profileImageUrl'],
      );
}
