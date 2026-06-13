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
  }) async {
    final res = await _api.post('/meal-plans', data: {
      'traineeId': traineeId,
      'name': name,
      'weekStartDate': weekStartDate,
      'targetCalories': targetCalories,
      'targetProteinGrams': targetProtein,
      'targetCarbsGrams': targetCarbs,
      'targetFatGrams': targetFat,
    });
    return (res.data['id'] ?? res.data).toString();
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
