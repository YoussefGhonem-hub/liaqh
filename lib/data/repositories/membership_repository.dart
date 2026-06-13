import '../models/membership_models.dart';
import '../services/api_service.dart';

class MembershipRepository {
  final ApiService _api;
  MembershipRepository(this._api);

  Future<List<MembershipPlanModel>> getGymPlans(String gymId) async {
    final res = await _api.get('/memberships/plans/gym/$gymId');
    return (res.data as List).map((j) => MembershipPlanModel.fromJson(j)).toList();
  }

  /// Plans the current user may assign (coach → own plans, gym admin → gym plans).
  Future<List<MembershipPlanModel>> getAssignablePlans() async {
    final res = await _api.get('/memberships/plans/assignable');
    return (res.data as List).map((j) => MembershipPlanModel.fromJson(j)).toList();
  }

  Future<String> createPlan({
    required String gymId,
    required String name,
    String? description,
    required double price,
    required int durationDays,
    String billingCycle = 'Monthly',
    bool isFree = false,
  }) async {
    final res = await _api.post('/memberships/plans', data: {
      'gymId': gymId,
      'name': name,
      if (description != null) 'description': description,
      'price': isFree ? 0 : price,
      'durationDays': durationDays,
      'billingCycle': billingCycle,
      'isFree': isFree,
    });
    return res.data['id'] as String;
  }

  Future<String> subscribe({
    required String traineeId,
    required String planId,
    required DateTime startDate,
    bool autoRenew = false,
  }) async {
    final res = await _api.post('/memberships/subscribe', data: {
      'traineeId': traineeId,
      'membershipPlanId': planId,
      'startDate': startDate.toIso8601String(),
      'autoRenew': autoRenew,
    });
    return res.data['id'] as String;
  }

  Future<void> updateStatus(String membershipId, String status, {DateTime? frozenUntil}) =>
      _api.patch('/memberships/$membershipId/status', data: {
        'status': status,
        if (frozenUntil != null) 'frozenUntil': frozenUntil.toIso8601String(),
      });

  Future<String> renew(String membershipId) async {
    final res = await _api.post('/memberships/$membershipId/renew');
    return res.data['id'] as String;
  }

  Future<List<TraineeMembershipModel>> getTraineeMemberships(String traineeId) async {
    final res = await _api.get('/memberships/trainee/$traineeId');
    return (res.data as List).map((j) => TraineeMembershipModel.fromJson(j)).toList();
  }

  Future<GymRevenueModel> getRevenue(String gymId) async {
    final res = await _api.get('/memberships/gym/$gymId/revenue');
    return GymRevenueModel.fromJson(res.data);
  }

  // ── Cash payment periods ────────────────────────────────────────────────────

  /// Server-paginated payment periods of a membership.
  Future<({List<MembershipPaymentModel> items, bool hasMore})> getPayments(
    String membershipId, {
    int page = 1,
    int pageSize = 8,
  }) async {
    final res = await _api.get('/memberships/$membershipId/payments',
        params: {'page': page, 'pageSize': pageSize});
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List)
        .map((j) => MembershipPaymentModel.fromJson(j))
        .toList();
    return (items: items, hasMore: data['hasNextPage'] as bool? ?? false);
  }

  /// status: 'Paid' | 'Unpaid' | 'Free'
  Future<void> setPaymentStatus(String paymentId, String status) =>
      _api.patch('/memberships/payments/$paymentId', data: {'status': status});
}
