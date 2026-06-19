import 'package:flutter/foundation.dart';
import '../data/models/coaching_models.dart';
import '../data/repositories/coaching_repository.dart';

class CoachingProvider extends ChangeNotifier {
  final CoachingRepository _repo;
  CoachingProvider(this._repo);

  WorkoutStats stats = WorkoutStats.empty();
  bool statsLoading = false;

  List<CoachLeaderboardEntry> leaderboard = [];
  bool leaderboardLoading = false;

  List<NeedsAttentionItem> needsAttention = [];
  bool needsLoading = false;

  String? error;

  Future<void> loadStats(String traineeId, {bool mine = false}) async {
    statsLoading = true;
    notifyListeners();
    try {
      stats = mine ? await _repo.myStats() : await _repo.stats(traineeId);
    } catch (e) {
      error = e.toString();
    }
    statsLoading = false;
    notifyListeners();
  }

  /// Returns the previous stats (so the UI can detect a new milestone).
  Future<WorkoutStats> setWeeklyGoalAndReload(
      int goal, String traineeId) async {
    await _repo.setWeeklyGoal(goal);
    await loadStats(traineeId);
    return stats;
  }

  Future<void> loadLeaderboard({String by = 'streak'}) async {
    leaderboardLoading = true;
    notifyListeners();
    try {
      leaderboard = await _repo.leaderboard(by: by);
    } catch (e) {
      error = e.toString();
    }
    leaderboardLoading = false;
    notifyListeners();
  }

  Future<void> loadNeedsAttention() async {
    needsLoading = true;
    notifyListeners();
    try {
      needsAttention = await _repo.needsAttention();
    } catch (e) {
      error = e.toString();
    }
    needsLoading = false;
    notifyListeners();
  }

  Future<int> broadcast(String title, String body) =>
      _repo.broadcast(title, body);
}
