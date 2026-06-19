import '../models/daily_workout_log.dart';
import '../services/api_service.dart';

class DailyWorkoutLogRepository {
  final ApiService _api;
  DailyWorkoutLogRepository(this._api);

  String _d(DateTime x) =>
      '${x.year}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';

  /// Logs for [traineeId] within an inclusive date range.
  Future<List<DailyWorkoutLog>> range(
      String traineeId, DateTime from, DateTime to) async {
    final res = await _api.get('/daily-workout-logs/$traineeId',
        params: {'from': _d(from), 'to': _d(to)});
    final items = res.data as List? ?? [];
    return items.map((j) => DailyWorkoutLog.fromJson(j)).toList();
  }

  /// Trainee logs whether they worked out on [date].
  Future<DailyWorkoutLog> log(DateTime date, bool didWorkout,
      {String? note}) async {
    final res = await _api.post('/daily-workout-logs', data: {
      'date': _d(date),
      'didWorkout': didWorkout,
      if (note != null && note.isNotEmpty) 'note': note,
    });
    return DailyWorkoutLog.fromJson(res.data as Map<String, dynamic>);
  }
}
