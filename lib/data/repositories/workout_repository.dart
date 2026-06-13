import 'dart:io';
import 'package:dio/dio.dart';
import '../models/workout_models.dart';
import '../services/api_service.dart';

class WorkoutRepository {
  final ApiService _api;
  WorkoutRepository(this._api);

  Future<WorkoutProgram> getProgram(String programId) async {
    final res = await _api.get('/workout-programs/$programId');
    return WorkoutProgram.fromJson(res.data);
  }

  /// Coach adds a comment to a specific workout exercise.
  Future<WorkoutComment> addComment(String workoutExerciseId, String text) async {
    final res = await _api.post('/workout-comments', data: {
      'workoutExerciseId': workoutExerciseId,
      'text': text,
    });
    return WorkoutComment.fromJson(res.data);
  }

  Future<void> deleteComment(String commentId) async {
    await _api.delete('/workout-comments/$commentId');
  }

  Future<WorkoutProgram?> getActiveProgram(String traineeId) async {
    final res = await _api.get('/workout-programs/trainee/$traineeId/active');
    if (res.statusCode == 204) return null;
    return WorkoutProgram.fromJson(res.data);
  }

  Future<String> createProgram({
    required String traineeId,
    required String name,
    required String periodType,
    required DateTime startDate,
    String? notes,
  }) async {
    final res = await _api.post('/workout-programs', data: {
      'traineeId': traineeId,
      'name': name,
      'periodType': periodType,
      'startDate': startDate.toIso8601String(),
      if (notes != null) 'notes': notes,
    });
    return res.data['id'].toString();
  }

  Future<String> addWorkoutDay({
    required String programId,
    required int dayNumber,
    required String dayName,
    required String muscleGroupFocus,
    String? notes,
    required List<Map<String, dynamic>> exercises,
  }) async {
    final res = await _api.post('/workout-programs/$programId/days', data: {
      'dayNumber': dayNumber,
      'dayName': dayName,
      'muscleGroupFocus': muscleGroupFocus,
      if (notes != null) 'notes': notes,
      'exercises': exercises,
    });
    return res.data['id'].toString();
  }

  Future<void> updateWorkoutDay({
    required String dayId,
    required String dayName,
    required String muscleGroupFocus,
    String? notes,
    required List<Map<String, dynamic>> exercises,
  }) async {
    await _api.put('/workout-programs/days/$dayId', data: {
      'dayName': dayName,
      'muscleGroupFocus': muscleGroupFocus,
      if (notes != null) 'notes': notes,
      'exercises': exercises,
    });
  }

  Future<void> deleteWorkoutDay(String dayId) async {
    await _api.delete('/workout-programs/days/$dayId');
  }

  Future<List<Exercise>> getExercises({String? search, String? muscleGroup, int page = 1}) async {
    final res = await _api.get('/exercises', params: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (muscleGroup != null) 'muscleGroup': muscleGroup,
      'page': page,
      'pageSize': 50,
    });
    final data = res.data;
    final items = data is Map ? (data['items'] as List? ?? []) : (data as List? ?? []);
    return items.map((j) => Exercise.fromJson(j)).toList();
  }

  Future<String> createCustomExercise({
    required String nameEn,
    String? nameAr,
    required String muscleGroup,
    String? equipment,
    String? descriptionEn,
    String? imageUrl,
    String? videoUrl,
  }) async {
    final res = await _api.post('/exercises', data: {
      'nameEn': nameEn,
      if (nameAr != null) 'nameAr': nameAr,
      'muscleGroup': muscleGroup,
      if (equipment != null) 'equipment': equipment,
      if (descriptionEn != null) 'descriptionEn': descriptionEn,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
    });
    return res.data['id'].toString();
  }

  Future<String> uploadExerciseImage(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
    });
    final res = await _api.uploadFile('/exercises/upload-image', formData);
    return res.data['url'];
  }

  // ── Workout templates (coach) ───────────────────────────────────────────────
  Future<List<WorkoutTemplate>> getTemplates() async {
    final res = await _api.get('/workout-templates');
    return (res.data as List).map((j) => WorkoutTemplate.fromJson(j)).toList();
  }

  Future<String> createTemplate({
    required String name,
    required String periodType,
    String? notes,
    String? attachmentUrl,
  }) async {
    final res = await _api.post('/workout-templates', data: {
      'name': name,
      'periodType': periodType,
      if (notes != null) 'notes': notes,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
    });
    return res.data['id'].toString();
  }

  /// Templates reuse the program day endpoint — a template IS a program row.
  Future<String> addTemplateDay({
    required String templateId,
    required int dayNumber,
    required String dayName,
    required String muscleGroupFocus,
    String? notes,
    required List<Map<String, dynamic>> exercises,
  }) =>
      addWorkoutDay(
        programId: templateId,
        dayNumber: dayNumber,
        dayName: dayName,
        muscleGroupFocus: muscleGroupFocus,
        notes: notes,
        exercises: exercises,
      );

  Future<String> assignTemplate(String templateId, String traineeId) async {
    final res = await _api.post(
        '/workout-templates/$templateId/assign?traineeId=$traineeId');
    return res.data['id'].toString();
  }

  Future<void> deleteTemplate(String templateId) async {
    await _api.delete('/workout-templates/$templateId');
  }

  Future<String> uploadTemplateFile(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
          filename: file.path.split(RegExp(r'[/\\]')).last),
    });
    final res = await _api.uploadFile('/workout-templates/upload-file', formData);
    return res.data['url'];
  }

  Future<List<WorkoutHistoryLog>> getHistory(String traineeId, {int page = 1}) async {
    final res = await _api.get('/workout-logs/trainee/$traineeId',
        params: {'page': page});
    return (res.data as List).map((j) => WorkoutHistoryLog.fromJson(j)).toList();
  }

  Future<void> logWorkoutDay({
    required String traineeId,
    required String workoutDayId,
    required DateTime trainedOn,
    required bool allWeightsPrescribed,
    String? traineeNotes,
    int? overallEffort,
    required List<Map<String, dynamic>> sets,
  }) async {
    await _api.post('/workout-logs', data: {
      'traineeId': traineeId,
      'workoutDayId': workoutDayId,
      'trainedOn': trainedOn.toIso8601String(),
      'allWeightsPrescribed': allWeightsPrescribed,
      if (traineeNotes != null) 'traineeNotes': traineeNotes,
      if (overallEffort != null) 'overallEffort': overallEffort,
      'sets': sets,
    });
  }
}
