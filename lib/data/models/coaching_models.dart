class WorkoutStats {
  final int currentStreak;
  final int longestStreak;
  final int totalWorkouts;
  final int thisWeekCount;
  final int weeklyGoal;
  final List<String> badges;

  WorkoutStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalWorkouts,
    required this.thisWeekCount,
    required this.weeklyGoal,
    required this.badges,
  });

  factory WorkoutStats.empty() => WorkoutStats(
        currentStreak: 0,
        longestStreak: 0,
        totalWorkouts: 0,
        thisWeekCount: 0,
        weeklyGoal: 4,
        badges: const [],
      );

  factory WorkoutStats.fromJson(Map<String, dynamic> j) => WorkoutStats(
        currentStreak: j['currentStreak'] ?? 0,
        longestStreak: j['longestStreak'] ?? 0,
        totalWorkouts: j['totalWorkouts'] ?? 0,
        thisWeekCount: j['thisWeekCount'] ?? 0,
        weeklyGoal: j['weeklyGoal'] ?? 4,
        badges: (j['badges'] as List? ?? []).map((e) => e.toString()).toList(),
      );
}

class CoachLeaderboardEntry {
  final String traineeId;
  final String name;
  final String? profileImageUrl;
  final int value;

  CoachLeaderboardEntry({
    required this.traineeId,
    required this.name,
    this.profileImageUrl,
    required this.value,
  });

  factory CoachLeaderboardEntry.fromJson(Map<String, dynamic> j) =>
      CoachLeaderboardEntry(
        traineeId: j['traineeId'].toString(),
        name: j['name'] ?? '',
        profileImageUrl: j['profileImageUrl'],
        value: j['value'] ?? 0,
      );
}

class NeedsAttentionItem {
  final String traineeId;
  final String userId;
  final String name;
  final String? profileImageUrl;
  final List<String> flags;

  NeedsAttentionItem({
    required this.traineeId,
    required this.userId,
    required this.name,
    this.profileImageUrl,
    required this.flags,
  });

  factory NeedsAttentionItem.fromJson(Map<String, dynamic> j) =>
      NeedsAttentionItem(
        traineeId: j['traineeId'].toString(),
        userId: j['userId'].toString(),
        name: j['name'] ?? '',
        profileImageUrl: j['profileImageUrl'],
        flags: (j['flags'] as List? ?? []).map((e) => e.toString()).toList(),
      );
}
