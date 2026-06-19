class MealPlan {
  final String id;
  final String name;
  final String weekStartDate;
  final bool isActive;
  final int targetCalories;
  final int targetProteinGrams;
  final int targetCarbsGrams;
  final int targetFatGrams;
  final int durationMonths;
  final String? attachmentUrl;
  final List<MealPlanDay> days;

  MealPlan({
    required this.id,
    required this.name,
    required this.weekStartDate,
    required this.isActive,
    required this.targetCalories,
    required this.targetProteinGrams,
    required this.targetCarbsGrams,
    required this.targetFatGrams,
    this.durationMonths = 1,
    this.attachmentUrl,
    required this.days,
  });

  bool get isFile => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  factory MealPlan.fromJson(Map<String, dynamic> j) => MealPlan(
        id: j['id'].toString(),
        name: j['name'] ?? '',
        weekStartDate: j['weekStartDate'] ?? '',
        isActive: j['isActive'] ?? false,
        targetCalories: j['targetCalories'] ?? 0,
        targetProteinGrams: j['targetProteinGrams'] ?? 0,
        targetCarbsGrams: j['targetCarbsGrams'] ?? 0,
        targetFatGrams: j['targetFatGrams'] ?? 0,
        durationMonths: j['durationMonths'] ?? 1,
        attachmentUrl: j['attachmentUrl'],
        days: (j['days'] as List? ?? [])
            .map((d) => MealPlanDay.fromJson(d))
            .toList(),
      );

  double get totalWeekCalories => days.fold(0, (s, d) => s + d.totalCalories);
  double get totalWeekProtein  => days.fold(0, (s, d) => s + d.totalProtein);
  double get totalWeekCarbs    => days.fold(0, (s, d) => s + d.totalCarbs);
  double get totalWeekFat      => days.fold(0, (s, d) => s + d.totalFat);
}

class MealPlanDay {
  final String id;
  final int dayOfWeek;
  final String? notes;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<Meal> meals;

  MealPlanDay({
    required this.id,
    required this.dayOfWeek,
    this.notes,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.meals,
  });

  factory MealPlanDay.fromJson(Map<String, dynamic> j) => MealPlanDay(
        id: j['id'].toString(),
        dayOfWeek: j['dayOfWeek'] ?? 0,
        notes: j['notes'],
        totalCalories: (j['totalCalories'] as num?)?.toDouble() ?? 0,
        totalProtein:  (j['totalProtein']  as num?)?.toDouble() ?? 0,
        totalCarbs:    (j['totalCarbs']    as num?)?.toDouble() ?? 0,
        totalFat:      (j['totalFat']      as num?)?.toDouble() ?? 0,
        meals: (j['meals'] as List? ?? []).map((m) => Meal.fromJson(m)).toList(),
      );

  static const _dayNames = [
    'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday',
  ];
  static const _dayNamesAr = [
    'الأحد','الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت',
  ];

  String get dayName   => dayOfWeek >= 0 && dayOfWeek < 7 ? _dayNames[dayOfWeek]   : 'Day $dayOfWeek';
  String get dayNameAr => dayOfWeek >= 0 && dayOfWeek < 7 ? _dayNamesAr[dayOfWeek] : 'يوم $dayOfWeek';
}

class Meal {
  final String id;
  final String mealType;
  final String? timeOfDay;
  final int? durationMinutes;
  final String? notes;
  final bool isRejected;
  final String? rejectionReason;
  final List<MealFoodItem> foodItems;

  Meal({
    required this.id,
    required this.mealType,
    this.timeOfDay,
    this.durationMinutes,
    this.notes,
    this.isRejected = false,
    this.rejectionReason,
    required this.foodItems,
  });

  factory Meal.fromJson(Map<String, dynamic> j) => Meal(
        id: j['id'].toString(),
        mealType: j['mealType'] ?? '',
        timeOfDay: j['timeOfDay'],
        durationMinutes: j['durationMinutes'],
        notes: j['notes'],
        isRejected: j['isRejected'] ?? false,
        rejectionReason: j['rejectionReason'],
        foodItems: (j['foodItems'] as List? ?? [])
            .map((f) => MealFoodItem.fromJson(f))
            .toList(),
      );

  double get totalCalories => foodItems.fold(0, (s, f) => s + f.caloriesCalculated);
  double get totalProtein  => foodItems.fold(0, (s, f) => s + f.proteinCalculated);
  double get totalCarbs    => foodItems.fold(0, (s, f) => s + f.carbsCalculated);
  double get totalFat      => foodItems.fold(0, (s, f) => s + f.fatCalculated);

  static const _icons = {
    'Breakfast':'🌅','MidMorning':'🍎','Lunch':'🌞',
    'Afternoon':'🫐','Dinner':'🌙','PreWorkout':'⚡','PostWorkout':'💪',
  };
  String get mealTypeEmoji => _icons[mealType] ?? '🍽️';
}

class MealFoodItem {
  final String id;
  final String? foodId;
  final String foodNameEn;
  final String foodNameAr;
  final double weightGrams;
  final double caloriesCalculated;
  final double proteinCalculated;
  final double carbsCalculated;
  final double fatCalculated;

  MealFoodItem({
    required this.id,
    this.foodId,
    required this.foodNameEn,
    required this.foodNameAr,
    required this.weightGrams,
    required this.caloriesCalculated,
    required this.proteinCalculated,
    required this.carbsCalculated,
    required this.fatCalculated,
  });

  factory MealFoodItem.fromJson(Map<String, dynamic> j) => MealFoodItem(
        id: j['id'].toString(),
        foodId: j['foodId']?.toString(),
        foodNameEn: j['foodNameEn'] ?? '',
        foodNameAr: j['foodNameAr'] ?? '',
        weightGrams:         (j['weightGrams']         as num?)?.toDouble() ?? 0,
        caloriesCalculated:  (j['caloriesCalculated']  as num?)?.toDouble() ?? 0,
        proteinCalculated:   (j['proteinCalculated']   as num?)?.toDouble() ?? 0,
        carbsCalculated:     (j['carbsCalculated']     as num?)?.toDouble() ?? 0,
        fatCalculated:       (j['fatCalculated']       as num?)?.toDouble() ?? 0,
      );
}

class Food {
  final String id;
  final String nameEn;
  final String nameAr;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final String category;
  final String? imageUrl;

  /// When set (>0), the food is measured by count: grams = count × gramsPerUnit.
  final double? gramsPerUnit;
  final String? unitNameEn;
  final String? unitNameAr;

  Food({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.category,
    this.imageUrl,
    this.gramsPerUnit,
    this.unitNameEn,
    this.unitNameAr,
  });

  bool get isCountBased => gramsPerUnit != null && gramsPerUnit! > 0;

  factory Food.fromJson(Map<String, dynamic> j) => Food(
        id: j['id'].toString(),
        nameEn: j['nameEn'] ?? '',
        nameAr: j['nameAr'] ?? '',
        caloriesPer100g: (j['caloriesPer100g'] as num?)?.toDouble() ?? 0,
        proteinPer100g:  (j['proteinPer100g']  as num?)?.toDouble() ?? 0,
        carbsPer100g:    (j['carbsPer100g']    as num?)?.toDouble() ?? 0,
        fatPer100g:      (j['fatPer100g']      as num?)?.toDouble() ?? 0,
        category: j['category'] ?? '',
        imageUrl: j['imageUrl'],
        gramsPerUnit: (j['gramsPerUnit'] as num?)?.toDouble(),
        unitNameEn: j['unitNameEn'],
        unitNameAr: j['unitNameAr'],
      );

  double caloriesFor(double grams) => caloriesPer100g * grams / 100;
  double proteinFor(double grams)  => proteinPer100g  * grams / 100;
  double carbsFor(double grams)    => carbsPer100g    * grams / 100;
  double fatFor(double grams)      => fatPer100g      * grams / 100;
}

class ShoppingList {
  final String mealPlanId;
  final List<ShoppingItem> items;
  ShoppingList({required this.mealPlanId, required this.items});

  factory ShoppingList.fromJson(Map<String, dynamic> j) => ShoppingList(
        mealPlanId: j['mealPlanId']?.toString() ?? '',
        items: (j['items'] as List? ?? [])
            .map((i) => ShoppingItem.fromJson(i))
            .toList(),
      );
}

class ShoppingItem {
  final String foodNameEn;
  final String foodNameAr;
  final double totalGrams;
  final String category;
  final double? estimatedPrice;
  bool checked;

  ShoppingItem({
    required this.foodNameEn,
    required this.foodNameAr,
    required this.totalGrams,
    required this.category,
    this.estimatedPrice,
    this.checked = false,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> j) => ShoppingItem(
        foodNameEn: j['foodNameEn'] ?? '',
        foodNameAr: j['foodNameAr'] ?? '',
        totalGrams: (j['totalGrams'] as num?)?.toDouble() ?? 0,
        category: j['category'] ?? '',
        estimatedPrice: (j['estimatedPrice'] as num?)?.toDouble(),
      );
}

// In-memory draft used only inside AddMealScreen
class FoodItemDraft {
  final Food food;
  double grams;
  FoodItemDraft({required this.food, required this.grams});

  double get calories => food.caloriesFor(grams);
  double get protein  => food.proteinFor(grams);
  double get carbs    => food.carbsFor(grams);
  double get fat      => food.fatFor(grams);

  Map<String, dynamic> toJson() => {'foodId': food.id, 'weightGrams': grams};
}
