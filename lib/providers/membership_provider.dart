import 'package:flutter/material.dart';
import '../data/models/membership_models.dart';
import '../data/repositories/membership_repository.dart';
import '../data/services/notification_service.dart';

class MembershipProvider extends ChangeNotifier {
  final MembershipRepository _repo;
  MembershipProvider(this._repo);

  List<MembershipPlanModel> _plans = [];
  List<TraineeMembershipModel> _traineeMemberships = [];
  GymRevenueModel? _revenue;
  bool _loading = false;
  bool _loadingMemberships = true;
  String? _error;

  List<MembershipPlanModel> get plans => _plans;
  List<TraineeMembershipModel> get traineeMemberships => _traineeMemberships;
  GymRevenueModel? get revenue => _revenue;
  bool get loading => _loading;
  bool get loadingMemberships => _loadingMemberships;
  String? get error => _error;

  Future<void> loadPlans(String gymId) async {
    _setLoading(true);
    try {
      _plans = await _repo.getGymPlans(gymId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Plans the current user may assign (coach → own plans, gym admin → gym plans).
  Future<void> loadAssignablePlans() async {
    _setLoading(true);
    try {
      _plans = await _repo.getAssignablePlans();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> createPlan({
    required String gymId,
    required String name,
    String? description,
    required double price,
    required int durationDays,
    String billingCycle = 'Monthly',
    bool isFree = false,
    bool reloadCoachPlans = false,
  }) async {
    _setLoading(true);
    try {
      await _repo.createPlan(
        gymId: gymId, name: name, description: description,
        price: price, durationDays: durationDays, billingCycle: billingCycle,
        isFree: isFree,
      );
      if (reloadCoachPlans) {
        await loadAssignablePlans();
      } else {
        await loadPlans(gymId);
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> subscribe({
    required String traineeId,
    required String planId,
    required DateTime startDate,
    bool autoRenew = false,
    String planName = '',
  }) async {
    _setLoading(true);
    try {
      await _repo.subscribe(
          traineeId: traineeId, planId: planId,
          startDate: startDate, autoRenew: autoRenew);
      await loadTraineeMemberships(traineeId);
      NotificationService.notifySubscriptionActivated(
          traineeId: traineeId,
          planName: planName.isNotEmpty ? planName : 'Membership');
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateStatus(String membershipId, String status,
      {DateTime? frozenUntil, required String traineeId}) async {
    _setLoading(true);
    try {
      await _repo.updateStatus(membershipId, status, frozenUntil: frozenUntil);
      await loadTraineeMemberships(traineeId);
      NotificationService.notifyMembershipStatusChanged(
          traineeId: traineeId, status: status);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> renew(String membershipId,
      {required String traineeId, String planName = ''}) async {
    _setLoading(true);
    try {
      await _repo.renew(membershipId);
      await loadTraineeMemberships(traineeId);
      NotificationService.notifyMembershipRenewed(
          traineeId: traineeId,
          planName: planName.isNotEmpty ? planName : 'Membership');
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> loadTraineeMemberships(String traineeId) async {
    _loadingMemberships = true;
    notifyListeners();
    try {
      _traineeMemberships = await _repo.getTraineeMemberships(traineeId);
    } catch (_) {}
    _loadingMemberships = false;
    notifyListeners();
  }

  // ── Cash payment periods (server-paginated) ─────────────────────────────────
  final Map<String, List<MembershipPaymentModel>> _payments = {};
  final Map<String, int> _paymentsPage = {};
  final Map<String, bool> _paymentsHasMore = {};
  final Set<String> _loadingPayments = {};

  List<MembershipPaymentModel> paymentsFor(String membershipId) =>
      _payments[membershipId] ?? const [];
  bool isLoadingPayments(String membershipId) =>
      _loadingPayments.contains(membershipId);
  bool paymentsHasMore(String membershipId) =>
      _paymentsHasMore[membershipId] ?? false;

  /// Loads the first page (reset) or a fresh reload keeping the loaded count.
  Future<void> loadPayments(String membershipId, {int? keepCount}) async {
    _loadingPayments.add(membershipId);
    notifyListeners();
    try {
      // Re-fetch all currently loaded items in one page so a status change
      // doesn't collapse the list back to page 1.
      final pageSize = keepCount != null && keepCount > 8 ? keepCount : 8;
      final res =
          await _repo.getPayments(membershipId, page: 1, pageSize: pageSize);
      _payments[membershipId] = res.items;
      _paymentsHasMore[membershipId] = res.hasMore;
      _paymentsPage[membershipId] = (res.items.length / 8).ceil().clamp(1, 9999);
    } catch (_) {
    } finally {
      _loadingPayments.remove(membershipId);
      notifyListeners();
    }
  }

  Future<void> loadMorePayments(String membershipId) async {
    if (!paymentsHasMore(membershipId) ||
        _loadingPayments.contains(membershipId)) {
      return;
    }
    final nextPage = (_paymentsPage[membershipId] ?? 1) + 1;
    _loadingPayments.add(membershipId);
    notifyListeners();
    try {
      final res = await _repo.getPayments(membershipId, page: nextPage);
      _payments[membershipId] = [
        ...?_payments[membershipId],
        ...res.items,
      ];
      _paymentsHasMore[membershipId] = res.hasMore;
      _paymentsPage[membershipId] = nextPage;
    } catch (_) {
    } finally {
      _loadingPayments.remove(membershipId);
      notifyListeners();
    }
  }

  /// status: 'Paid' | 'Unpaid' | 'Free'
  Future<bool> setPaymentStatus(
      String membershipId, String paymentId, String status) async {
    try {
      await _repo.setPaymentStatus(paymentId, status);
      // Re-fetch the items already loaded so the toggled row updates in place.
      final loaded = _payments[membershipId]?.length ?? 8;
      await loadPayments(membershipId, keepCount: loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> loadRevenue(String gymId) async {
    _setLoading(true);
    try {
      _revenue = await _repo.getRevenue(gymId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading(bool v) {
    _loading = v; _error = null; notifyListeners();
  }

  void _setError(String msg) {
    _error = msg; _loading = false; notifyListeners();
  }
}
