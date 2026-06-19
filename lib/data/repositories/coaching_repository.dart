import '../models/coaching_models.dart';
import '../services/api_service.dart';

class CoachingRepository {
  final ApiService _api;
  CoachingRepository(this._api);

  Future<WorkoutStats> stats(String traineeId) async {
    final res = await _api.get('/coaching/stats/$traineeId');
    return WorkoutStats.fromJson(res.data as Map<String, dynamic>);
  }

  Future<WorkoutStats> myStats() async {
    final res = await _api.get('/coaching/stats/me');
    return WorkoutStats.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> setWeeklyGoal(int goal) async {
    await _api.put('/coaching/weekly-goal', data: {'goal': goal});
  }

  Future<List<CoachLeaderboardEntry>> leaderboard({String by = 'streak'}) async {
    final res = await _api.get('/coaching/leaderboard', params: {'by': by});
    final items = res.data as List? ?? [];
    return items.map((j) => CoachLeaderboardEntry.fromJson(j)).toList();
  }

  Future<List<NeedsAttentionItem>> needsAttention() async {
    final res = await _api.get('/coaching/needs-attention');
    final items = res.data as List? ?? [];
    return items.map((j) => NeedsAttentionItem.fromJson(j)).toList();
  }

  Future<int> broadcast(String title, String body) async {
    final res = await _api
        .post('/coaching/broadcast', data: {'title': title, 'body': body});
    return (res.data is Map ? res.data['sent'] : res.data) as int? ?? 0;
  }
}
