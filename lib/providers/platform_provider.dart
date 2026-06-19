import 'package:flutter/material.dart';
import '../data/models/platform_models.dart';
import '../data/repositories/platform_repository.dart';

class PlatformProvider extends ChangeNotifier {
  final PlatformRepository _repo;
  PlatformProvider(this._repo);

  // ── Overview ──
  PlatformOverview? overview;
  bool overviewLoading = false;
  String? overviewError;

  Future<void> loadOverview() async {
    overviewLoading = true;
    overviewError = null;
    notifyListeners();
    try {
      overview = await _repo.getOverview();
    } catch (e) {
      overviewError = e.toString();
    }
    overviewLoading = false;
    notifyListeners();
  }

  // ── Gyms ──
  List<GymSummary> gyms = [];
  bool gymsLoading = false;
  String? gymsError;

  Future<void> loadGyms({String? search, bool? isActive}) async {
    gymsLoading = true;
    gymsError = null;
    notifyListeners();
    try {
      gyms = await _repo.getGyms(search: search, isActive: isActive);
    } catch (e) {
      gymsError = e.toString();
    }
    gymsLoading = false;
    notifyListeners();
  }

  // ── Gym detail ──
  GymDetail? gymDetail;
  bool gymDetailLoading = false;
  String? gymDetailError;

  Future<void> loadGymDetail(String id) async {
    gymDetailLoading = true;
    gymDetailError = null;
    gymDetail = null;
    notifyListeners();
    try {
      gymDetail = await _repo.getGymDetail(id);
    } catch (e) {
      gymDetailError = e.toString();
    }
    gymDetailLoading = false;
    notifyListeners();
  }

  Future<void> setGymStatus(String id, bool isActive) async {
    await _repo.setGymStatus(id, isActive);
    // Refresh detail if currently viewing the same gym.
    if (gymDetail?.id == id) {
      await loadGymDetail(id);
    }
    // Refresh list if loaded.
    if (gyms.isNotEmpty) {
      await loadGyms();
    }
  }

  // ── Revenue ──
  PlatformRevenue? revenue;
  bool revenueLoading = false;
  String? revenueError;

  Future<void> loadRevenue() async {
    revenueLoading = true;
    revenueError = null;
    notifyListeners();
    try {
      revenue = await _repo.getRevenue();
    } catch (e) {
      revenueError = e.toString();
    }
    revenueLoading = false;
    notifyListeners();
  }

  // ── Users ──
  PaginatedUsers? users;
  bool usersLoading = false;
  String? usersError;
  String? usersRoleFilter;
  String? usersSearch;

  Future<void> loadUsers({
    String? role,
    String? search,
    int page = 1,
  }) async {
    usersLoading = true;
    usersError = null;
    usersRoleFilter = role;
    usersSearch = search;
    notifyListeners();
    try {
      users = await _repo.getUsers(role: role, search: search, page: page);
    } catch (e) {
      usersError = e.toString();
    }
    usersLoading = false;
    notifyListeners();
  }

  Future<void> setUserStatus(String id, bool isActive) async {
    await _repo.setUserStatus(id, isActive);
    if (users != null) {
      await loadUsers(role: usersRoleFilter, search: usersSearch);
    }
    if (userDetail?.id == id) {
      await loadUserDetail(id);
    }
  }

  /// Soft-delete a user account (Platform Owner). Returns true on success.
  Future<bool> deleteUser(String id) async {
    try {
      await _repo.deleteUser(id);
      if (users != null) {
        await loadUsers(role: usersRoleFilter, search: usersSearch);
      }
      return true;
    } catch (e) {
      usersError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── User detail ──
  UserDetail? userDetail;
  bool userDetailLoading = false;
  String? userDetailError;

  Future<void> loadUserDetail(String id) async {
    userDetailLoading = true;
    userDetailError = null;
    notifyListeners();
    try {
      userDetail = await _repo.getUserDetail(id);
    } catch (e) {
      userDetailError = e.toString();
    }
    userDetailLoading = false;
    notifyListeners();
  }

  // ── Plans (per gym) ──
  List<PlatformPlan> plans = [];
  bool plansLoading = false;
  String? plansError;

  Future<void> loadPlans(String gymId) async {
    plansLoading = true;
    plansError = null;
    notifyListeners();
    try {
      plans = await _repo.getGymPlans(gymId);
    } catch (e) {
      plansError = e.toString();
    }
    plansLoading = false;
    notifyListeners();
  }

  Future<void> createPlan({
    required String gymId,
    required String name,
    String? description,
    required double price,
    required int durationDays,
    required String billingCycle,
  }) async {
    await _repo.createPlan(
      gymId: gymId,
      name: name,
      description: description,
      price: price,
      durationDays: durationDays,
      billingCycle: billingCycle,
    );
    await loadPlans(gymId);
  }

  Future<void> updatePlan({
    required String gymId,
    required String id,
    required String name,
    String? description,
    required double price,
    required int durationDays,
    required String billingCycle,
    required bool isActive,
  }) async {
    await _repo.updatePlan(
      id: id,
      name: name,
      description: description,
      price: price,
      durationDays: durationDays,
      billingCycle: billingCycle,
      isActive: isActive,
    );
    await loadPlans(gymId);
  }

  Future<void> deletePlan({required String gymId, required String id}) async {
    await _repo.deletePlan(id);
    await loadPlans(gymId);
  }

  // ── Announcements ──
  bool announcementSending = false;
  String? announcementError;

  Future<int> sendAnnouncement({
    required String title,
    required String body,
    String? targetRole,
    String? gymId,
  }) async {
    announcementSending = true;
    announcementError = null;
    notifyListeners();
    try {
      final sent = await _repo.sendAnnouncement(
        title: title,
        body: body,
        targetRole: targetRole,
        gymId: gymId,
      );
      announcementSending = false;
      notifyListeners();
      return sent;
    } catch (e) {
      announcementError = e.toString();
      announcementSending = false;
      notifyListeners();
      rethrow;
    }
  }

  // ── Coaches ──
  List<PlatformCoach> coaches = [];
  bool coachesLoading = false;
  bool coachesLoadingMore = false;
  bool _coachesHasMore = false;
  int _coachesPage = 1;
  String? _coachesSearch;
  String? coachesError;
  static const _coachesPageSize = 20;
  bool get coachesHasMore => _coachesHasMore;

  Future<void> loadCoaches({String? search}) async {
    coachesLoading = true;
    coachesError = null;
    _coachesPage = 1;
    _coachesSearch = search;
    notifyListeners();
    try {
      final res = await _repo.getCoaches(
          search: search, page: 1, pageSize: _coachesPageSize);
      coaches = res.items;
      _coachesHasMore = res.hasNextPage;
    } catch (e) {
      coachesError = e.toString();
    }
    coachesLoading = false;
    notifyListeners();
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
}
