import 'package:flutter/foundation.dart';
import '../data/models/daily_workout_log.dart';
import '../data/repositories/daily_workout_log_repository.dart';

class DailyWorkoutLogProvider extends ChangeNotifier {
  final DailyWorkoutLogRepository _repo;
  DailyWorkoutLogProvider(this._repo);

  bool loading = false;
  bool saving = false;
  String? error;

  /// Status per day keyed by yyyy-MM-dd → true/false (worked out or not).
  final Map<String, bool> _status = {};
  /// Nutrition-followed status per day (null = not answered).
  final Map<String, bool?> _nutrition = {};
  List<DailyWorkoutLog> history = [];

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Returns the logged status for a day, or null if not logged yet.
  bool? statusFor(DateTime day) => _status[_key(day)];

  /// Returns whether the trainee followed nutrition on a day (null = unanswered).
  bool? nutritionFor(DateTime day) => _nutrition[_key(day)];

  /// Loads the current week + recent history (last ~60 days) for a trainee.
  Future<void> load(String traineeId) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 60));
      final logs = await _repo.range(traineeId, from, now);
      _status.clear();
      _nutrition.clear();
      for (final l in logs) {
        _status[_key(l.date)] = l.didWorkout;
        _nutrition[_key(l.date)] = l.followedNutrition;
      }
      history = logs; // already newest-first from the server
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  /// Trainee logs today's (or any day's) status; updates local state.
  /// Pass [followedNutrition] to record the nutrition check-in too; omit it to
  /// keep the day's existing nutrition value.
  Future<bool> log(DateTime day, bool didWorkout,
      {bool? followedNutrition}) async {
    saving = true;
    notifyListeners();
    try {
      final nutrition = followedNutrition ?? _nutrition[_key(day)];
      final saved =
          await _repo.log(day, didWorkout, followedNutrition: nutrition);
      _status[_key(saved.date)] = saved.didWorkout;
      _nutrition[_key(saved.date)] = saved.followedNutrition;
      // Refresh history entry.
      history.removeWhere((l) => _key(l.date) == _key(saved.date));
      history.insert(0, saved);
      history.sort((a, b) => b.date.compareTo(a.date));
      saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      saving = false;
      notifyListeners();
      return false;
    }
  }
}
