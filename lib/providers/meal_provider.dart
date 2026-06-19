import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fitnessapp/data/models/meal_models.dart';
import 'package:fitnessapp/data/repositories/meal_repository.dart';
import 'package:fitnessapp/data/services/notification_service.dart';

class MealProvider extends ChangeNotifier {
  final MealRepository _repo;
  MealProvider(this._repo);

  MealPlan? currentPlan;
  List<Food> foods = [];
  ShoppingList? shoppingList;
  bool loading = false;
  String? error;

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  void _setError(Object e) {
    error = e.toString();
    loading = false;
    notifyListeners();
  }

  // ── Active plan ────────────────────────────────────────────────────────────

  Future<void> loadActivePlan(String traineeId) async {
    _setLoading(true);
    try {
      currentPlan = await _repo.getActivePlan(traineeId);
      error = null;
    } catch (e) {
      _setError(e);
      return;
    }
    _setLoading(false);
  }

  /// Creates a new meal plan and then loads it as the current active plan.
  /// Returns the new plan's id on success, null on failure.
  Future<String?> createPlan({
    required String traineeId,
    required String name,
    required String weekStartDate,
    required int targetCalories,
    required int targetProtein,
    required int targetCarbs,
    required int targetFat,
    int durationMonths = 1,
    String? attachmentUrl,
    String coachName = '',
  }) async {
    _setLoading(true);
    try {
      final planId = await _repo.createMealPlan(
        traineeId: traineeId,
        name: name,
        weekStartDate: weekStartDate,
        targetCalories: targetCalories,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
        durationMonths: durationMonths,
        attachmentUrl: attachmentUrl,
      );
      await loadActivePlan(traineeId);
      if (coachName.isNotEmpty) {
        NotificationService.notifyMealPlanAssigned(
            traineeId: traineeId, planName: name, coachName: coachName);
      }
      return planId;
    } catch (e) {
      _setError(e);
      return null;
    }
  }

  /// Uploads a PDF/image file and returns its stored URL (for file-based plans).
  Future<String?> uploadPlanFile(File file) async {
    try {
      return await _repo.uploadMealPlanFile(file);
    } catch (e) {
      _setError(e);
      return null;
    }
  }

  /// Trainee rejects a meal with a reason; reloads the active plan afterwards.
  Future<bool> rejectMeal({
    required String mealId,
    required String reason,
    required String traineeId,
  }) async {
    _setLoading(true);
    try {
      await _repo.rejectMeal(mealId, reason);
      await loadActivePlan(traineeId);
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  /// Coach replaces a rejected meal's food items; reloads the plan afterwards.
  Future<bool> replaceMeal({
    required String mealId,
    required String planId,
    String? timeOfDay,
    String? notes,
    required List<Map<String, dynamic>> foodItems,
  }) async {
    _setLoading(true);
    try {
      await _repo.replaceMeal(
        mealId: mealId,
        timeOfDay: timeOfDay,
        notes: notes,
        foodItems: foodItems,
      );
      currentPlan = await _repo.getMealPlan(planId);
      error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // ── Meals ──────────────────────────────────────────────────────────────────

  Future<bool> addMeal({
    required String planId,
    required String dayId,
    required String mealType,
    required String timeOfDay,
    int durationMinutes = 30,
    String? notes,
    required List<Map<String, dynamic>> foodItems,
    String traineeId = '',
    String coachName = '',
  }) async {
    _setLoading(true);
    try {
      await _repo.addMeal(
        planId: planId,
        dayId: dayId,
        mealType: mealType,
        timeOfDay: timeOfDay,
        durationMinutes: durationMinutes,
        notes: notes,
        foodItems: foodItems,
      );
      final updated = await _repo.getMealPlan(planId);
      currentPlan = updated;
      error = null;
      _setLoading(false);
      if (traineeId.isNotEmpty && coachName.isNotEmpty) {
        NotificationService.notifyMealPlanUpdated(
            traineeId: traineeId, coachName: coachName);
      }
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  /// Copies all meals from [dayId] into [targetDayIds]; reloads the plan.
  /// Returns the number of meals copied, or null on failure.
  Future<int?> duplicateDay({
    required String planId,
    required String dayId,
    required List<String> targetDayIds,
    bool replaceExisting = false,
  }) async {
    _setLoading(true);
    try {
      final copied = await _repo.duplicateDay(
        planId: planId,
        dayId: dayId,
        targetDayIds: targetDayIds,
        replaceExisting: replaceExisting,
      );
      currentPlan = await _repo.getMealPlan(planId);
      error = null;
      _setLoading(false);
      return copied;
    } catch (e) {
      _setError(e);
      return null;
    }
  }

  Future<bool> removeMeal({
    required String planId,
    required String dayId,
    required String mealId,
  }) async {
    _setLoading(true);
    try {
      await _repo.removeMeal(planId: planId, dayId: dayId, mealId: mealId);
      final updated = await _repo.getMealPlan(planId);
      currentPlan = updated;
      error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // ── Food library ───────────────────────────────────────────────────────────

  Future<void> loadFoods({String? search, String? category}) async {
    _setLoading(true);
    try {
      foods = await _repo.getFoods(search: search, category: category);
      error = null;
    } catch (e) {
      _setError(e);
      return;
    }
    _setLoading(false);
  }

  /// Creates a custom food and prepends it to the in-memory list. Returns the
  /// created food, or null on failure.
  Future<Food?> createFood({
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
    try {
      final food = await _repo.createFood(
        nameEn: nameEn,
        nameAr: nameAr,
        category: category,
        caloriesPer100g: caloriesPer100g,
        proteinPer100g: proteinPer100g,
        carbsPer100g: carbsPer100g,
        fatPer100g: fatPer100g,
        gramsPerUnit: gramsPerUnit,
        unitNameEn: unitNameEn,
        unitNameAr: unitNameAr,
      );
      foods = [food, ...foods];
      error = null;
      notifyListeners();
      return food;
    } catch (e) {
      _setError(e);
      return null;
    }
  }

  // ── Meal logging ───────────────────────────────────────────────────────────

  Future<bool> logMeal({
    required String traineeId,
    required String mealId,
    required String status,
    String? notes,
  }) async {
    _setLoading(true);
    try {
      await _repo.logMeal(
        traineeId: traineeId,
        mealId: mealId,
        status: status,
        notes: notes,
      );
      error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // ── Shopping list ──────────────────────────────────────────────────────────

  Future<void> loadShoppingList(String planId) async {
    _setLoading(true);
    try {
      shoppingList = await _repo.getShoppingList(planId);
      error = null;
    } catch (e) {
      _setError(e);
      return;
    }
    _setLoading(false);
  }
}
