import 'dart:math' as math;

/// Biological sex used by the Mifflin-St Jeor BMR equation.
enum Sex { male, female }

/// Daily activity level → TDEE multiplier (BRD methodology).
enum ActivityLevel { sedentary, light, moderate, active, veryActive }

extension ActivityLevelX on ActivityLevel {
  double get factor {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
    }
  }

  String get labelEn {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.light:
        return 'Light';
      case ActivityLevel.moderate:
        return 'Moderate';
      case ActivityLevel.active:
        return 'Active';
      case ActivityLevel.veryActive:
        return 'Very active';
    }
  }

  String get labelAr {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'خامل';
      case ActivityLevel.light:
        return 'نشاط خفيف';
      case ActivityLevel.moderate:
        return 'نشاط متوسط';
      case ActivityLevel.active:
        return 'نشيط';
      case ActivityLevel.veryActive:
        return 'نشيط جدًا';
    }
  }

  String get hintEn {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Little or no exercise';
      case ActivityLevel.light:
        return '1–3 days / week';
      case ActivityLevel.moderate:
        return '3–5 days / week';
      case ActivityLevel.active:
        return '6–7 days / week';
      case ActivityLevel.veryActive:
        return 'Hard daily / physical job';
    }
  }
}

/// The coach's fitness goal for the trainee.
enum FitnessGoal { cut, bulk, maintain, recomp }

extension FitnessGoalX on FitnessGoal {
  /// Maps a server [TraineeGoal] string to the enum (case-insensitive).
  static FitnessGoal fromString(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'cut':
        return FitnessGoal.cut;
      case 'bulk':
        return FitnessGoal.bulk;
      case 'recomp':
        return FitnessGoal.recomp;
      case 'maintain':
      default:
        return FitnessGoal.maintain;
    }
  }

  String get labelEn {
    switch (this) {
      case FitnessGoal.cut:
        return 'Cut';
      case FitnessGoal.bulk:
        return 'Bulk';
      case FitnessGoal.maintain:
        return 'Maintain';
      case FitnessGoal.recomp:
        return 'Recomp';
    }
  }

  String get labelAr {
    switch (this) {
      case FitnessGoal.cut:
        return 'تنشيف';
      case FitnessGoal.bulk:
        return 'تضخيم';
      case FitnessGoal.maintain:
        return 'محافظة';
      case FitnessGoal.recomp:
        return 'إعادة تكوين';
    }
  }
}

/// The full set of computed daily nutrition targets shown to the coach as a
/// reference before building (or uploading) a plan. All formulas follow the
/// BRD methodology (Mifflin-St Jeor BMR, activity-factor TDEE, goal-adjusted
/// calories, protein/kg, fat ≈ 25% kcal, carbs as remainder, water 35 ml/kg).
class NutritionTargets {
  final double bmr; // kcal
  final double tdee; // kcal
  final int calories; // kcal/day (goal-adjusted)
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final double waterLiters;

  // Suggested extras
  final double bmi;
  final String bmiCategory;
  final int proteinPerMeal; // assuming 4 meals/day
  final int proteinPct; // macro split %
  final int carbsPct;
  final int fatPct;
  final double weeklyRateKg; // expected weight change per week
  final int fiberGrams;

  const NutritionTargets({
    required this.bmr,
    required this.tdee,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.waterLiters,
    required this.bmi,
    required this.bmiCategory,
    required this.proteinPerMeal,
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
    required this.weeklyRateKg,
    required this.fiberGrams,
  });

  /// Computes targets from the trainee's measurements plus the coach-supplied
  /// [sex] and [activity] (not stored on the trainee record).
  factory NutritionTargets.compute({
    required Sex sex,
    required double weightKg,
    required double heightCm,
    required int age,
    required ActivityLevel activity,
    required FitnessGoal goal,
    int mealsPerDay = 4,
  }) {
    // BMR — Mifflin-St Jeor
    final bmr = sex == Sex.male
        ? 10 * weightKg + 6.25 * heightCm - 5 * age + 5
        : 10 * weightKg + 6.25 * heightCm - 5 * age - 161;

    final tdee = bmr * activity.factor;

    // Calories by goal
    double calories;
    double proteinPerKg;
    switch (goal) {
      case FitnessGoal.cut:
        calories = tdee * 0.80; // −20%
        proteinPerKg = 2.2;
        break;
      case FitnessGoal.bulk:
        calories = tdee * 1.125; // +12.5%
        proteinPerKg = 1.8;
        break;
      case FitnessGoal.recomp:
        calories = tdee; // maintenance
        proteinPerKg = 2.0;
        break;
      case FitnessGoal.maintain:
        calories = tdee;
        proteinPerKg = 1.6;
        break;
    }

    final protein = proteinPerKg * weightKg; // g
    final fatKcal = calories * 0.25;
    final fat = fatKcal / 9.0; // g
    final proteinKcal = protein * 4.0;
    final carbsKcal = math.max(0.0, calories - proteinKcal - fatKcal);
    final carbs = carbsKcal / 4.0; // g

    final water = weightKg * 0.035; // liters (35 ml/kg)

    // Extras
    final heightM = heightCm / 100.0;
    final bmi = heightM > 0 ? weightKg / (heightM * heightM) : 0.0;
    final bmiCategory = bmi < 18.5
        ? 'Underweight'
        : bmi < 25
            ? 'Normal'
            : bmi < 30
                ? 'Overweight'
                : 'Obese';

    final totalKcal = calories <= 0 ? 1 : calories;
    final proteinPct = (proteinKcal / totalKcal * 100).round();
    final fatPct = (fatKcal / totalKcal * 100).round();
    final carbsPct = math.max(0, 100 - proteinPct - fatPct);

    // Weekly rate: ~7700 kcal per kg
    final dailyDelta = calories - tdee;
    final weeklyRate = dailyDelta * 7 / 7700.0;

    // Fiber ~14 g per 1000 kcal
    final fiber = (calories / 1000.0 * 14).round();

    return NutritionTargets(
      bmr: bmr,
      tdee: tdee,
      calories: calories.round(),
      proteinGrams: protein.round(),
      carbsGrams: carbs.round(),
      fatGrams: fat.round(),
      waterLiters: double.parse(water.toStringAsFixed(1)),
      bmi: double.parse(bmi.toStringAsFixed(1)),
      bmiCategory: bmiCategory,
      proteinPerMeal: mealsPerDay > 0 ? (protein / mealsPerDay).round() : 0,
      proteinPct: proteinPct,
      carbsPct: carbsPct,
      fatPct: fatPct,
      weeklyRateKg: double.parse(weeklyRate.toStringAsFixed(2)),
      fiberGrams: fiber,
    );
  }
}
