import '../models/paged_result.dart';
import '../models/platform_models.dart';
import '../services/api_service.dart';

class PlatformRepository {
  final ApiService _api;
  PlatformRepository(this._api);

  Future<PlatformOverview> getOverview() async {
    final res = await _api.get('/platform/overview');
    return PlatformOverview.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<GymSummary>> getGyms({String? search, bool? isActive}) async {
    final res = await _api.get('/platform/gyms', params: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (isActive != null) 'isActive': isActive,
    });
    final items = res.data as List? ?? [];
    return items
        .map((j) => GymSummary.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<GymDetail> getGymDetail(String id) async {
    final res = await _api.get('/platform/gyms/$id');
    return GymDetail.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> setGymStatus(String id, bool isActive) async {
    await _api.patch('/platform/gyms/$id/status', data: {'isActive': isActive});
  }

  Future<PlatformRevenue> getRevenue() async {
    final res = await _api.get('/platform/revenue');
    return PlatformRevenue.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PaginatedUsers> getUsers({
    String? role,
    String? gymId,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await _api.get('/platform/users', params: {
      if (role != null && role.isNotEmpty) 'role': role,
      if (gymId != null && gymId.isNotEmpty) 'gymId': gymId,
      if (search != null && search.isNotEmpty) 'search': search,
      'pageNumber': page,
      'pageSize': pageSize,
    });
    return PaginatedUsers.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> setUserStatus(String id, bool isActive) async {
    await _api.patch('/platform/users/$id/status', data: {'isActive': isActive});
  }

  Future<void> deleteUser(String id) async {
    await _api.delete('/platform/users/$id');
  }

  Future<UserDetail> getUserDetail(String id) async {
    final res = await _api.get('/platform/users/$id');
    return UserDetail.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<PlatformPlan>> getGymPlans(String gymId) async {
    final res = await _api.get('/memberships/plans/gym/$gymId',
        params: {'includeInactive': true});
    final items = res.data as List? ?? [];
    return items
        .map((j) => PlatformPlan.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> createPlan({
    required String gymId,
    required String name,
    String? description,
    required double price,
    required int durationDays,
    required String billingCycle,
  }) async {
    await _api.post('/memberships/plans', data: {
      'gymId': gymId,
      'name': name,
      if (description != null) 'description': description,
      'price': price,
      'durationDays': durationDays,
      'billingCycle': billingCycle,
    });
  }

  Future<void> updatePlan({
    required String id,
    required String name,
    String? description,
    required double price,
    required int durationDays,
    required String billingCycle,
    required bool isActive,
  }) async {
    await _api.put('/memberships/plans/$id', data: {
      'name': name,
      if (description != null) 'description': description,
      'price': price,
      'durationDays': durationDays,
      'billingCycle': billingCycle,
      'isActive': isActive,
    });
  }

  Future<void> deletePlan(String id) async {
    await _api.delete('/memberships/plans/$id');
  }

  Future<int> sendAnnouncement({
    required String title,
    required String body,
    String? targetRole,
    String? gymId,
  }) async {
    final res = await _api.post('/platform/announcements', data: {
      'title': title,
      'body': body,
      if (targetRole != null) 'targetRole': targetRole,
      if (gymId != null) 'gymId': gymId,
    });
    final data = res.data as Map<String, dynamic>?;
    return (data?['sent'] as num?)?.toInt() ?? 0;
  }

  Future<PagedResult<PlatformCoach>> getCoaches(
      {String? search, int page = 1, int pageSize = 20}) async {
    final res = await _api.get('/platform/coaches', params: {
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page,
      'pageSize': pageSize,
    });
    return PagedResult.fromJson(
        res.data, (j) => PlatformCoach.fromJson(j));
  }
}
