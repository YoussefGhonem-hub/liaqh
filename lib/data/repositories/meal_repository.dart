import 'dart:io';

import 'package:dio/dio.dart';

import '../models/meal_models.dart';
import '../services/api_service.dart';

class MealRepository {
  final ApiService _api;
  MealRepository(this._api);

  Future<MealPlan?> getActivePlan(String traineeId) async {
    final res = await _api.get('/meal-plans/trainee/$traineeId/active');
    if (res.statusCode == 204 || res.data == null) return null;
    return MealPlan.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MealPlan> getMealPlan(String planId) async {
    final res = await _api.get('/meal-plans/$planId');
    return MealPlan.fromJson(res.data as Map<String, dynamic>);
  }

  Future<String> createMealPlan({
    required String traineeId,
    required String name,
    required String weekStartDate,
    required int targetCalories,
    required int targetProtein,
    required int targetCarbs,
    required int targetFat,
    int durationMonths = 1,
    String? attachmentUrl,
  }) async {
    final res = await _api.post('/meal-plans', data: {
      'traineeId': traineeId,
      'name': name,
      'weekStartDate': weekStartDate,
      'targetCalories': targetCalories,
      'targetProteinGrams': targetProtein,
      'targetCarbsGrams': targetCarbs,
      'targetFatGrams': targetFat,
      'durationMonths': durationMonths,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
    });
    return (res.data['id'] ?? res.data).toString();
  }

  /// Uploads a PDF/image for a file-based plan and returns the stored URL.
  Future<String> uploadMealPlanFile(File file) async {
    final fileName = file.path.split(RegExp(r'[\\/]')).last;
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    final res = await _api.uploadFile('/meal-plans/upload-file', form);
    return (res.data['url'] ?? res.data).toString();
  }

  /// Trainee rejects a meal with a reason → coach is notified.
  Future<void> rejectMeal(String mealId, String reason) async {
    await _api.post('/meals/$mealId/reject', data: {'reason': reason});
  }

  /// Coach replaces a rejected meal's food items → trainee is notified.
  Future<void> replaceMeal({
    required String mealId,
    String? timeOfDay,
    String? notes,
    required List<Map<String, dynamic>> foodItems,
  }) async {
    await _api.put('/meals/$mealId/replace', data: {
      if (timeOfDay != null) 'timeOfDay': timeOfDay,
      if (notes != null) 'notes': notes,
      'foodItems': foodItems,
    });
  }

  Future<String> addMeal({
    required String planId,
    required String dayId,
    required String mealType,
    required String timeOfDay,
    int durationMinutes = 30,
    String? notes,
    required List<Map<String, dynamic>> foodItems,
  }) async {
    final res = await _api.post('/meal-plans/$planId/days/$dayId/meals', data: {
      'mealType': mealType,
      'timeOfDay': timeOfDay,
      'durationMinutes': durationMinutes,
      if (notes != null) 'notes': notes,
      'foodItems': foodItems,
    });
    return (res.data['id'] ?? res.data).toString();
  }

  /// Copies all meals from [dayId] into [targetDayIds]. Returns how many meals
  /// were copied.
  Future<int> duplicateDay({
    required String planId,
    required String dayId,
    required List<String> targetDayIds,
    bool replaceExisting = false,
  }) async {
    final res = await _api.post(
      '/meal-plans/$planId/days/$dayId/duplicate',
      data: {
        'targetDayIds': targetDayIds,
        'replaceExisting': replaceExisting,
      },
    );
    return (res.data is Map ? res.data['copiedMeals'] : res.data) as int? ?? 0;
  }

  Future<void> removeMeal({
    required String planId,
    required String dayId,
    required String mealId,
  }) async {
    await _api.delete('/meal-plans/$planId/days/$dayId/meals/$mealId');
  }

  Future<List<Food>> getFoods({String? search, String? category, int pageSize = 50}) async {
    final params = <String, dynamic>{'pageSize': pageSize};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category != 'All') params['category'] = category;
    final res = await _api.get('/foods', params: params);
    final data = res.data;
    final list = data is Map ? (data['items'] as List? ?? []) : (data as List? ?? []);
    return list.map((j) => Food.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Coach/gym adds a custom food to the library; returns the created food.
  Future<Food> createFood({
    required String nameEn,
    String? nameAr,
    required String category,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    double? gramsPerUnit,
    String? unitNameEn,
    String? unitNameAr,
  }) async {
    final res = await _api.post('/foods', data: {
      'nameEn': nameEn,
      if (nameAr != null && nameAr.isNotEmpty) 'nameAr': nameAr,
      'category': category,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      if (gramsPerUnit != null && gramsPerUnit > 0) 'gramsPerUnit': gramsPerUnit,
      if (unitNameEn != null && unitNameEn.isNotEmpty) 'unitNameEn': unitNameEn,
      if (unitNameAr != null && unitNameAr.isNotEmpty) 'unitNameAr': unitNameAr,
    });
    return Food.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> logMeal({
    required String traineeId,
    required String mealId,
    required String status,
    String? notes,
  }) async {
    await _api.post('/meal-logs', data: {
      'traineeId': traineeId,
      'mealId': mealId,
      'status': status,
      if (notes != null) 'notes': notes,
    });
  }

  Future<ShoppingList> getShoppingList(String planId) async {
    final res = await _api.get('/meal-logs/shopping-list/$planId');
    return ShoppingList.fromJson(res.data as Map<String, dynamic>);
  }
}
