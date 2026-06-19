import '../models/paged_result.dart';
import '../models/trainee_models.dart';
import '../services/api_service.dart';

class TraineeRepository {
  final ApiService _api;
  TraineeRepository(this._api);

  Future<PagedResult<TraineeSummary>> getMyTrainees(
      {int page = 1, int pageSize = 20}) async {
    final res = await _api
        .get('/trainees/my', params: {'page': page, 'pageSize': pageSize});
    return PagedResult.fromJson(res.data, (j) => TraineeSummary.fromJson(j));
  }

  /// Logged-in trainee fetches their own full profile.
  Future<TraineeDetail> getMyProfile() async {
    final res = await _api.get('/trainees/me');
    return TraineeDetail.fromJson(res.data as Map<String, dynamic>);
  }

  Future<String> createTrainee(CreateTraineeRequest req) async {
    final res = await _api.post('/trainees', data: req.toJson());
    return res.data.toString();
  }
}
