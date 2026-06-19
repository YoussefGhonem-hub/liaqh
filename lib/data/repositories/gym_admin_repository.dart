import '../models/gym_admin_models.dart';
import '../models/paged_result.dart';
import '../models/trainee_models.dart';
import '../services/api_service.dart';

class GymAdminRepository {
  final ApiService _api;
  GymAdminRepository(this._api);

  Future<GymAdminDashboard> getDashboard() async {
    final res = await _api.get('/gym-admin/dashboard');
    return GymAdminDashboard.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<UnpaidTrainee>> getUnpaidTrainees() async {
    final res = await _api.get('/gym-admin/unpaid-trainees');
    return (res.data as List).map((j) => UnpaidTrainee.fromJson(j)).toList();
  }

  Future<PagedResult<GymCoach>> getCoaches(
      {String? search, int page = 1, int pageSize = 20}) async {
    final res = await _api.get('/gym-admin/coaches', params: {
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page,
      'pageSize': pageSize,
    });
    return PagedResult.fromJson(res.data, (j) => GymCoach.fromJson(j));
  }

  Future<String> createCoach({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? bio,
  }) async {
    final res = await _api.post('/gym-admin/coaches', data: {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (bio != null) 'bio': bio,
    });
    return res.data['userId'].toString();
  }

  Future<List<TraineeSummary>> getCoachTrainees(String coachUserId,
      {int page = 1, int pageSize = 50}) async {
    final res = await _api.get('/gym-admin/coaches/$coachUserId/trainees',
        params: {'page': page, 'pageSize': pageSize});
    final items = (res.data['items'] as List? ?? res.data as List);
    return items.map((j) => TraineeSummary.fromJson(j)).toList();
  }

  Future<String> createTrainee({
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
    final res = await _api.post('/gym-admin/trainees', data: {
      'coachUserId': coachUserId,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'goal': goal,
      'heightCm': heightCm,
      'currentWeightKg': currentWeightKg,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    });
    return res.data['id'].toString();
  }

  Future<void> reassign(String traineeId, String coachUserId) =>
      _api.patch('/gym-admin/trainees/$traineeId/reassign',
          data: {'coachUserId': coachUserId});
}
