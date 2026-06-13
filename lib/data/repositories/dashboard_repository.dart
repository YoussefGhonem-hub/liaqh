import '../models/dashboard_models.dart';
import '../services/api_service.dart';

class DashboardRepository {
  final ApiService _api;
  DashboardRepository(this._api);

  Future<CoachDashboard> getCoachDashboard() async {
    final res = await _api.get('/dashboard/coach');
    return CoachDashboard.fromJson(res.data);
  }

  Future<List<LeaderboardEntry>> getLeaderboard(String gymId, {int top = 20}) async {
    final res = await _api.get('/dashboard/leaderboard',
        params: {'gymId': gymId, 'top': top});
    return (res.data as List).map((j) => LeaderboardEntry.fromJson(j)).toList();
  }
}
