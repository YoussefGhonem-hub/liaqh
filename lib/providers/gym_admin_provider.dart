import 'package:flutter/material.dart';
import '../data/models/gym_admin_models.dart';
import '../data/models/trainee_models.dart';
import '../data/repositories/gym_admin_repository.dart';

class GymAdminProvider extends ChangeNotifier {
  final GymAdminRepository _repo;
  GymAdminProvider(this._repo);

  GymAdminDashboard? dashboard;
  bool dashboardLoading = false;

  List<UnpaidTrainee> unpaidTrainees = [];
  bool unpaidLoading = false;

  Future<void> loadUnpaidTrainees() async {
    unpaidLoading = true;
    notifyListeners();
    try {
      unpaidTrainees = await _repo.getUnpaidTrainees();
    } catch (e) {
      error = e.toString();
    } finally {
      unpaidLoading = false;
      notifyListeners();
    }
  }

  List<GymCoach> coaches = [];
  bool coachesLoading = false;
  bool coachesLoadingMore = false;
  bool _coachesHasMore = false;
  int _coachesPage = 1;
  String? _coachesSearch;
  static const _coachesPageSize = 20;
  bool get coachesHasMore => _coachesHasMore;

  // trainees per coach (by coachUserId)
  final Map<String, List<TraineeSummary>> _coachTrainees = {};
  bool busy = false;
  String? error;

  List<TraineeSummary> traineesOf(String coachUserId) =>
      _coachTrainees[coachUserId] ?? const [];

  Future<void> loadDashboard() async {
    dashboardLoading = true;
    notifyListeners();
    try {
      dashboard = await _repo.getDashboard();
    } catch (e) {
      error = e.toString();
    } finally {
      dashboardLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCoaches({String? search}) async {
    coachesLoading = true;
    _coachesPage = 1;
    _coachesSearch = search;
    notifyListeners();
    try {
      final res = await _repo.getCoaches(
          search: search, page: 1, pageSize: _coachesPageSize);
      coaches = res.items;
      _coachesHasMore = res.hasNextPage;
    } catch (e) {
      error = e.toString();
    } finally {
      coachesLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreCoaches() async {
    if (coachesLoadingMore || !_coachesHasMore || coachesLoading) return;
    coachesLoadingMore = true;
    notifyListeners();
    try {
      final res = await _repo.getCoaches(
          search: _coachesSearch,
          page: _coachesPage + 1,
          pageSize: _coachesPageSize);
      coaches = [...coaches, ...res.items];
      _coachesPage += 1;
      _coachesHasMore = res.hasNextPage;
    } catch (_) {}
    coachesLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadCoachTrainees(String coachUserId) async {
    try {
      _coachTrainees[coachUserId] = await _repo.getCoachTrainees(coachUserId);
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createCoach({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? bio,
  }) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await _repo.createCoach(
        email: email, password: password, firstName: firstName,
        lastName: lastName, phoneNumber: phoneNumber, bio: bio,
      );
      await loadCoaches();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> createTrainee({
    required String coachUserId,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String goal,
    required double heightCm,
    required double currentWeightKg,
    String? phoneNumber,
  }) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await _repo.createTrainee(
        coachUserId: coachUserId, email: email, password: password,
        firstName: firstName, lastName: lastName, goal: goal,
        heightCm: heightCm, currentWeightKg: currentWeightKg,
        phoneNumber: phoneNumber,
      );
      await loadCoachTrainees(coachUserId);
      await loadCoaches();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> reassign(String traineeId, String coachUserId) async {
    try {
      await _repo.reassign(traineeId, coachUserId);
      await loadCoaches();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
