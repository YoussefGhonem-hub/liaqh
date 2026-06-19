class DailyWorkoutLog {
  final DateTime date;
  final bool didWorkout;
  final String? note;

  DailyWorkoutLog({required this.date, required this.didWorkout, this.note});

  factory DailyWorkoutLog.fromJson(Map<String, dynamic> j) => DailyWorkoutLog(
        date: DateTime.parse(j['date'].toString()),
        didWorkout: j['didWorkout'] ?? false,
        note: j['note'],
      );
}
