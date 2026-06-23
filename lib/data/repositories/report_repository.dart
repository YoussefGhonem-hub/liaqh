import '../models/trainee_report_models.dart';
import '../services/api_service.dart';

class ReportRepository {
  final ApiService _api;
  ReportRepository(this._api);

  String _d(DateTime x) =>
      '${x.year}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';

  Future<TraineeReport> getTraineeReport(
      String traineeId, DateTime from, DateTime to) async {
    final res = await _api.get('/reports/trainee/$traineeId',
        params: {'from': _d(from), 'to': _d(to)});
    return TraineeReport.fromJson(res.data as Map<String, dynamic>);
  }
}
