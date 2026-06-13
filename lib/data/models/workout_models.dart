class WorkoutProgram {
  final String id;
  final String name;
  final String periodType;
  final String startDate;
  final String endDate;
  final bool isActive;
  final String? notes;
  final String? attachmentUrl;
  final List<WorkoutDay> days;

  WorkoutProgram({
    required this.id,
    required this.name,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.notes,
    this.attachmentUrl,
    required this.days,
  });

  factory WorkoutProgram.fromJson(Map<String, dynamic> j) => WorkoutProgram(
        id: j['id'],
        name: j['name'],
        periodType: j['periodType'],
        startDate: j['startDate'],
        endDate: j['endDate'],
        isActive: j['isActive'] ?? false,
        notes: j['notes'],
        attachmentUrl: j['attachmentUrl'],
        days: (j['days'] as List? ?? [])
            .map((d) => WorkoutDay.fromJson(d))
            .toList(),
      );
}

/// A reusable coach-owned workout template (structured days OR an uploaded file).
class WorkoutTemplate {
  final String id;
  final String name;
  final String periodType;
  final int dayCount;
  final String? attachmentUrl;
  final String? notes;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.periodType,
    required this.dayCount,
    this.attachmentUrl,
    this.notes,
  });

  bool get isFile => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  factory WorkoutTemplate.fromJson(Map<String, dynamic> j) => WorkoutTemplate(
        id: j['id'],
        name: j['name'] ?? '',
        periodType: j['periodType'] ?? 'Week',
        dayCount: j['dayCount'] ?? 0,
        attachmentUrl: j['attachmentUrl'],
        notes: j['notes'],
      );
}

class WorkoutDay {
  final String id;
  final int dayNumber;
  final String dayName;
  final String muscleGroupFocus;
  final String? notes;
  final List<WorkoutExerciseItem> exercises;

  WorkoutDay({
    required this.id,
    required this.dayNumber,
    required this.dayName,
    required this.muscleGroupFocus,
    this.notes,
    required this.exercises,
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> j) => WorkoutDay(
        id: j['id'],
        dayNumber: j['dayNumber'],
        dayName: j['dayName'],
        muscleGroupFocus: j['muscleGroupFocus'],
        notes: j['notes'],
        exercises: (j['exercises'] as List? ?? [])
            .map((e) => WorkoutExerciseItem.fromJson(e))
            .toList(),
      );
}

class WorkoutExerciseItem {
  final String id;
  final String exerciseId;
  final String exerciseNameEn;
  final String exerciseNameAr;
  final String muscleGroup;
  final int sets;
  final String repsTarget;
  final int restSeconds;
  final double? startingWeightKg;
  final int orderIndex;
  final String? notes;
  final String? videoUrl;
  final List<WorkoutComment> comments;

  WorkoutExerciseItem({
    required this.id,
    required this.exerciseId,
    required this.exerciseNameEn,
    required this.exerciseNameAr,
    required this.muscleGroup,
    required this.sets,
    required this.repsTarget,
    required this.restSeconds,
    this.startingWeightKg,
    required this.orderIndex,
    this.notes,
    this.videoUrl,
    this.comments = const [],
  });

  factory WorkoutExerciseItem.fromJson(Map<String, dynamic> j) => WorkoutExerciseItem(
        id: j['id'],
        exerciseId: j['exerciseId'],
        exerciseNameEn: j['exerciseNameEn'],
        exerciseNameAr: j['exerciseNameAr'],
        muscleGroup: j['muscleGroup'],
        sets: j['sets'],
        repsTarget: j['repsTarget'],
        restSeconds: j['restSeconds'],
        startingWeightKg: j['startingWeightKg'] != null
            ? (j['startingWeightKg'] as num).toDouble()
            : null,
        orderIndex: j['orderIndex'],
        notes: j['notes'],
        videoUrl: j['videoUrl'],
        comments: (j['comments'] as List? ?? [])
            .map((c) => WorkoutComment.fromJson(c))
            .toList(),
      );
}

class WorkoutComment {
  final String id;
  final String coachId;
  final String coachName;
  final String text;
  final String createdAt;

  WorkoutComment({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.text,
    required this.createdAt,
  });

  factory WorkoutComment.fromJson(Map<String, dynamic> j) => WorkoutComment(
        id: j['id'],
        coachId: j['coachId'] ?? '',
        coachName: j['coachName'] ?? '',
        text: j['text'] ?? '',
        createdAt: j['createdAt'] ?? '',
      );
}

class Exercise {
  final String id;
  final String nameEn;
  final String nameAr;
  final String muscleGroup;
  final String? equipment;
  final String? descriptionEn;
  final String? imageUrl;
  final String? videoUrl;
  final bool isCustom;

  Exercise({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.muscleGroup,
    this.equipment,
    this.descriptionEn,
    this.imageUrl,
    this.videoUrl,
    this.isCustom = false,
  });

  factory Exercise.fromJson(Map<String, dynamic> j) => Exercise(
        id: j['id'],
        nameEn: j['nameEn'],
        nameAr: j['nameAr'],
        muscleGroup: j['muscleGroup'],
        equipment: j['equipment'],
        descriptionEn: j['descriptionEn'],
        imageUrl: j['imageUrl'],
        videoUrl: j['videoUrl'],
        isCustom: j['isCustom'] ?? false,
      );
}

// ── Workout history (coach / trainee views) ──────────────────────────────────

class WorkoutHistoryLog {
  final String logId;
  final String trainedOn;
  final String dayName;
  final String muscleGroupFocus;
  final bool allWeightsPrescribed;
  final int? overallEffort;
  final String? traineeNotes;
  final List<ExerciseSetSummary> exercises;

  WorkoutHistoryLog({
    required this.logId,
    required this.trainedOn,
    required this.dayName,
    required this.muscleGroupFocus,
    required this.allWeightsPrescribed,
    this.overallEffort,
    this.traineeNotes,
    this.exercises = const [],
  });

  factory WorkoutHistoryLog.fromJson(Map<String, dynamic> j) => WorkoutHistoryLog(
        logId: j['logId'],
        trainedOn: j['trainedOn'],
        dayName: j['dayName'],
        muscleGroupFocus: j['muscleGroupFocus'],
        allWeightsPrescribed: j['allWeightsPrescribed'] ?? false,
        overallEffort: j['overallEffort'],
        traineeNotes: j['traineeNotes'],
        exercises: (j['exercises'] as List? ?? [])
            .map((e) => ExerciseSetSummary.fromJson(e))
            .toList(),
      );
}

class ExerciseSetSummary {
  final String exerciseNameEn;
  final String exerciseNameAr;
  final String prescribedReps;
  final double? prescribedWeightKg;
  final List<SetDetail> sets;

  ExerciseSetSummary({
    required this.exerciseNameEn,
    required this.exerciseNameAr,
    required this.prescribedReps,
    this.prescribedWeightKg,
    this.sets = const [],
  });

  factory ExerciseSetSummary.fromJson(Map<String, dynamic> j) => ExerciseSetSummary(
        exerciseNameEn: j['exerciseNameEn'],
        exerciseNameAr: j['exerciseNameAr'],
        prescribedReps: j['prescribedReps'],
        prescribedWeightKg: j['prescribedWeightKg'] != null
            ? (j['prescribedWeightKg'] as num).toDouble()
            : null,
        sets: (j['sets'] as List? ?? [])
            .map((s) => SetDetail.fromJson(s))
            .toList(),
      );
}

class SetDetail {
  final int setNo;
  final int reps;
  final double weightKg;
  final int? effort;

  SetDetail({
    required this.setNo,
    required this.reps,
    required this.weightKg,
    this.effort,
  });

  factory SetDetail.fromJson(Map<String, dynamic> j) => SetDetail(
        setNo: j['setNo'],
        reps: j['reps'],
        weightKg: (j['weightKg'] as num).toDouble(),
        effort: j['effort'],
      );
}

// ── Session logging (in-progress workout) ───────────────────────────────────

class SetLogDraft {
  int reps;
  double weightKg;
  int? effort;
  bool done;

  SetLogDraft({
    required this.reps,
    required this.weightKg,
    this.effort,
    this.done = false,
  });

  Map<String, dynamic> toJson(String workoutExerciseId, int setNumber) => {
        'workoutExerciseId': workoutExerciseId,
        'setNumber': setNumber,
        'repsCompleted': reps,
        'weightKgUsed': weightKg,
        if (effort != null) 'effortLevel': effort,
      };
}
