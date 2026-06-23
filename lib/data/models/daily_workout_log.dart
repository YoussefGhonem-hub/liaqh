class DailyWorkoutLog {
  final DateTime date;
  final bool didWorkout;
  final bool? followedNutrition;
  final String? note;

  DailyWorkoutLog({
    required this.date,
    required this.didWorkout,
    this.followedNutrition,
    this.note,
  });

  factory DailyWorkoutLog.fromJson(Map<String, dynamic> j) => DailyWorkoutLog(
        date: DateTime.parse(j['date'].toString()),
        didWorkout: j['didWorkout'] ?? false,
        followedNutrition: j['followedNutrition'],
        note: j['note'],
      );
}
