import 'package:flutter/material.dart';
import '../data/models/dashboard_models.dart';
import '../data/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repo;
  DashboardProvider(this._repo);

  CoachDashboard? _dashboard;
  List<LeaderboardEntry> _leaderboard = [];
  bool _loading = false;
  String? _error;

  CoachDashboard? get dashboard => _dashboard;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadDashboard() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _dashboard = await _repo.getCoachDashboard();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadLeaderboard(String gymId) async {
    try {
      _leaderboard = await _repo.getLeaderboard(gymId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }
}
