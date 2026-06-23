class WorkoutDayStatus {
  final DateTime date;
  final bool completed;
  WorkoutDayStatus({required this.date, required this.completed});
  factory WorkoutDayStatus.fromJson(Map<String, dynamic> j) => WorkoutDayStatus(
        date: DateTime.parse(j['date'].toString()),
        completed: j['completed'] ?? false,
      );
}

class RejectedMeal {
  final String mealType;
  final String? reason;
  RejectedMeal({required this.mealType, this.reason});
  factory RejectedMeal.fromJson(Map<String, dynamic> j) =>
      RejectedMeal(mealType: j['mealType'] ?? '', reason: j['reason']);
}

class ProgressiveOverload {
  final String exercise;
  final double fromKg;
  final double toKg;
  ProgressiveOverload(
      {required this.exercise, required this.fromKg, required this.toKg});
  factory ProgressiveOverload.fromJson(Map<String, dynamic> j) =>
      ProgressiveOverload(
        exercise: j['exercise'] ?? '',
        fromKg: (j['fromKg'] as num?)?.toDouble() ?? 0,
        toKg: (j['toKg'] as num?)?.toDouble() ?? 0,
      );
}

double? _d(dynamic v) => v == null ? null : (v as num).toDouble();

class TraineeReport {
  // 1
  final String fullName;
  final int? age;
  final double heightCm;
  final double currentWeightKg;
  final String goal;
  final String membershipStatus;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String coachName;
  // 2
  final bool hasInBody;
  final double? latestWeight, prevWeight, weightChange;
  final double? latestMuscle, prevMuscle, muscleChange;
  final double? latestBodyFat, prevBodyFat, bodyFatChange;
  final double? bodyWater;
  final int? visceralFat;
  final double? bmi;
  final double? bodyScore;
  final String bodyScoreTrend;
  // 3
  final int workoutsPlanned, workoutsCompleted, workoutCompletionRate;
  final List<WorkoutDayStatus> workoutDays;
  final String? bestExercise;
  final double? bestExerciseGainKg;
  final List<ProgressiveOverload> progressiveOverload;
  // 4 & 5
  final int mealDaysPlanned, mealDaysLogged, mealCompletionRate;
  final int avgCalories, avgProtein, avgCarbs, avgFat;
  final int targetCalories, targetProtein, targetCarbs, targetFat;
  final List<RejectedMeal> rejectedMeals;
  // 6
  final int adherenceScore;
  final String adherenceStatus;
  final int currentStreak;
  final List<String> badgesThisPeriod;
  final int pointsThisPeriod;
  final int? leaderboardRank;
  final String overallAssessment;

  TraineeReport({
    required this.fullName,
    this.age,
    required this.heightCm,
    required this.currentWeightKg,
    required this.goal,
    required this.membershipStatus,
    required this.periodStart,
    required this.periodEnd,
    required this.coachName,
    required this.hasInBody,
    this.latestWeight,
    this.prevWeight,
    this.weightChange,
    this.latestMuscle,
    this.prevMuscle,
    this.muscleChange,
    this.latestBodyFat,
    this.prevBodyFat,
    this.bodyFatChange,
    this.bodyWater,
    this.visceralFat,
    this.bmi,
    this.bodyScore,
    required this.bodyScoreTrend,
    required this.workoutsPlanned,
    required this.workoutsCompleted,
    required this.workoutCompletionRate,
    required this.workoutDays,
    this.bestExercise,
    this.bestExerciseGainKg,
    required this.progressiveOverload,
    required this.mealDaysPlanned,
    required this.mealDaysLogged,
    required this.mealCompletionRate,
    required this.avgCalories,
    required this.avgProtein,
    required this.avgCarbs,
    required this.avgFat,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.rejectedMeals,
    required this.adherenceScore,
    required this.adherenceStatus,
    required this.currentStreak,
    required this.badgesThisPeriod,
    required this.pointsThisPeriod,
    this.leaderboardRank,
    required this.overallAssessment,
  });

  factory TraineeReport.fromJson(Map<String, dynamic> j) => TraineeReport(
        fullName: j['fullName'] ?? '',
        age: j['age'],
        heightCm: _d(j['heightCm']) ?? 0,
        currentWeightKg: _d(j['currentWeightKg']) ?? 0,
        goal: j['goal'] ?? '',
        membershipStatus: j['membershipStatus'] ?? '',
        periodStart: DateTime.parse(j['periodStart'].toString()),
        periodEnd: DateTime.parse(j['periodEnd'].toString()),
        coachName: j['coachName'] ?? '',
        hasInBody: j['hasInBody'] ?? false,
        latestWeight: _d(j['latestWeight']),
        prevWeight: _d(j['prevWeight']),
        weightChange: _d(j['weightChange']),
        latestMuscle: _d(j['latestMuscle']),
        prevMuscle: _d(j['prevMuscle']),
        muscleChange: _d(j['muscleChange']),
        latestBodyFat: _d(j['latestBodyFat']),
        prevBodyFat: _d(j['prevBodyFat']),
        bodyFatChange: _d(j['bodyFatChange']),
        bodyWater: _d(j['bodyWater']),
        visceralFat: j['visceralFat'],
        bmi: _d(j['bmi']),
        bodyScore: _d(j['bodyScore']),
        bodyScoreTrend: j['bodyScoreTrend'] ?? 'flat',
        workoutsPlanned: j['workoutsPlanned'] ?? 0,
        workoutsCompleted: j['workoutsCompleted'] ?? 0,
        workoutCompletionRate: j['workoutCompletionRate'] ?? 0,
        workoutDays: (j['workoutDays'] as List? ?? [])
            .map((e) => WorkoutDayStatus.fromJson(e))
            .toList(),
        bestExercise: j['bestExercise'],
        bestExerciseGainKg: _d(j['bestExerciseGainKg']),
        progressiveOverload: (j['progressiveOverload'] as List? ?? [])
            .map((e) => ProgressiveOverload.fromJson(e))
            .toList(),
        mealDaysPlanned: j['mealDaysPlanned'] ?? 0,
        mealDaysLogged: j['mealDaysLogged'] ?? 0,
        mealCompletionRate: j['mealCompletionRate'] ?? 0,
        avgCalories: j['avgCalories'] ?? 0,
        avgProtein: j['avgProtein'] ?? 0,
        avgCarbs: j['avgCarbs'] ?? 0,
        avgFat: j['avgFat'] ?? 0,
        targetCalories: j['targetCalories'] ?? 0,
        targetProtein: j['targetProtein'] ?? 0,
        targetCarbs: j['targetCarbs'] ?? 0,
        targetFat: j['targetFat'] ?? 0,
        rejectedMeals: (j['rejectedMeals'] as List? ?? [])
            .map((e) => RejectedMeal.fromJson(e))
            .toList(),
        adherenceScore: j['adherenceScore'] ?? 0,
        adherenceStatus: j['adherenceStatus'] ?? '',
        currentStreak: j['currentStreak'] ?? 0,
        badgesThisPeriod:
            (j['badgesThisPeriod'] as List? ?? []).map((e) => e.toString()).toList(),
        pointsThisPeriod: j['pointsThisPeriod'] ?? 0,
        leaderboardRank: j['leaderboardRank'],
        overallAssessment: j['overallAssessment'] ?? '',
      );
}

/// Coach-entered sections 7 & 8 (not from backend).
class CoachAssessment {
  String summary;
  String whatWentWell;
  String needsImprovement;
  String behaviorNotes;
  String recommendedWorkout;
  String recommendedNutrition;
  String weightTarget;
  // Section 8 — next period plan
  String updatedGoal;
  String newTargetWeight;
  String programChanges;
  String nutritionAdjustments;
  String nextInBodyDate;
  String nextReportDate;

  CoachAssessment({
    this.summary = '',
    this.whatWentWell = '',
    this.needsImprovement = '',
    this.behaviorNotes = '',
    this.recommendedWorkout = '',
    this.recommendedNutrition = '',
    this.weightTarget = '',
    this.updatedGoal = '',
    this.newTargetWeight = '',
    this.programChanges = '',
    this.nutritionAdjustments = '',
    this.nextInBodyDate = '',
    this.nextReportDate = '',
  });
}
