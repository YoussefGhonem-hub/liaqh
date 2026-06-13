import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/workout_models.dart';
import '../data/repositories/workout_repository.dart';
import '../data/services/notification_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _repo;
  WorkoutProvider(this._repo);

  WorkoutProgram? _currentProgram;
  List<Exercise> _exercises = [];
  List<WorkoutHistoryLog> _history = [];
  List<WorkoutTemplate> _templates = [];
  bool _templatesLoading = false;
  bool _loading = false;
  String? _error;

  WorkoutProgram? get currentProgram => _currentProgram;
  List<Exercise> get exercises => _exercises;
  List<WorkoutHistoryLog> get history => _history;
  List<WorkoutTemplate> get templates => _templates;
  bool get templatesLoading => _templatesLoading;
  bool get loading => _loading;
  String? get error => _error;

  // ── Workout templates (coach) ───────────────────────────────────────────────
  Future<void> loadTemplates() async {
    _templatesLoading = true;
    notifyListeners();
    try {
      _templates = await _repo.getTemplates();
    } catch (e) {
      _error = e.toString();
    }
    _templatesLoading = false;
    notifyListeners();
  }

  Future<String?> createTemplate({
    required String name,
    required String periodType,
    String? notes,
    String? attachmentUrl,
  }) async {
    try {
      return await _repo.createTemplate(
        name: name,
        periodType: periodType,
        notes: notes,
        attachmentUrl: attachmentUrl,
      );
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> assignTemplate(String templateId, String traineeId) async {
    try {
      await _repo.assignTemplate(templateId, traineeId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Fetch a program/template (with days + exercises) without storing it as the
  /// current trainee program — used by the template day editor.
  Future<WorkoutProgram?> fetchProgram(String programId) async {
    try {
      return await _repo.getProgram(programId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> updateWorkoutDay({
    required String dayId,
    required String dayName,
    required String muscleGroupFocus,
    String? notes,
    required List<Map<String, dynamic>> exercises,
  }) async {
    try {
      await _repo.updateWorkoutDay(
        dayId: dayId,
        dayName: dayName,
        muscleGroupFocus: muscleGroupFocus,
        notes: notes,
        exercises: exercises,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteWorkoutDay(String dayId) async {
    try {
      await _repo.deleteWorkoutDay(dayId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteTemplate(String templateId) async {
    try {
      await _repo.deleteTemplate(templateId);
      _templates.removeWhere((t) => t.id == templateId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<String?> uploadTemplateFile(File file) async {
    try {
      return await _repo.uploadTemplateFile(file);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  void _setLoading(bool v) { _loading = v; _error = null; notifyListeners(); }
  void _setError(String e) { _error = e; _loading = false; notifyListeners(); }

  Future<void> loadProgram(String programId) async {
    _setLoading(true);
    try {
      _currentProgram = await _repo.getProgram(programId);
    } catch (e) { _setError(e.toString()); return; }
    _setLoading(false);
  }

  Future<void> loadActiveProgram(String traineeId) async {
    _setLoading(true);
    try {
      _currentProgram = await _repo.getActiveProgram(traineeId);
    } catch (e) { _setError(e.toString()); return; }
    _setLoading(false);
  }

  /// Coach adds a comment to a workout exercise, then refreshes the program.
  Future<bool> addComment(String workoutExerciseId, String text,
      {String? programId, String? traineeId}) async {
    try {
      await _repo.addComment(workoutExerciseId, text);
      await _refreshProgram(programId: programId, traineeId: traineeId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteComment(String commentId,
      {String? programId, String? traineeId}) async {
    try {
      await _repo.deleteComment(commentId);
      await _refreshProgram(programId: programId, traineeId: traineeId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> _refreshProgram({String? programId, String? traineeId}) async {
    try {
      if (programId != null) {
        _currentProgram = await _repo.getProgram(programId);
      } else if (traineeId != null) {
        _currentProgram = await _repo.getActiveProgram(traineeId);
      }
      notifyListeners();
    } catch (_) {/* keep existing program on refresh failure */}
  }

  Future<void> loadExercises({String? search, String? muscleGroup}) async {
    try {
      _exercises = await _repo.getExercises(search: search, muscleGroup: muscleGroup);
      notifyListeners();
    } catch (e) { _setError(e.toString()); }
  }

  Future<void> loadHistory(String traineeId) async {
    _setLoading(true);
    try {
      _history = await _repo.getHistory(traineeId);
    } catch (e) { _setError(e.toString()); return; }
    _setLoading(false);
  }

  Future<String?> createProgram({
    required String traineeId,
    required String name,
    required String periodType,
    required DateTime startDate,
    String? notes,
    String coachName = '',
  }) async {
    _setLoading(true);
    try {
      final id = await _repo.createProgram(
        traineeId: traineeId, name: name,
        periodType: periodType, startDate: startDate, notes: notes,
      );
      _setLoading(false);
      if (coachName.isNotEmpty) {
        NotificationService.notifyWorkoutPlanAssigned(
          traineeId: traineeId, planName: name, coachName: coachName);
      }
      return id;
    } catch (e) { _setError(e.toString()); return null; }
  }

  Future<String?> addWorkoutDay({
    required String programId,
    required int dayNumber,
    required String dayName,
    required String muscleGroupFocus,
    String? notes,
    required List<Map<String, dynamic>> exercises,
    String traineeId = '',
    String coachName = '',
  }) async {
    _setLoading(true);
    try {
      final id = await _repo.addWorkoutDay(
        programId: programId, dayNumber: dayNumber,
        dayName: dayName, muscleGroupFocus: muscleGroupFocus,
        notes: notes, exercises: exercises,
      );
      _setLoading(false);
      if (traineeId.isNotEmpty && coachName.isNotEmpty) {
        NotificationService.notifyWorkoutDayAdded(
          traineeId: traineeId, dayName: dayName, coachName: coachName);
      }
      return id;
    } catch (e) { _setError(e.toString()); return null; }
  }

  Future<bool> logWorkoutDay({
    required String traineeId,
    required String workoutDayId,
    required DateTime trainedOn,
    required bool allWeightsPrescribed,
    String? traineeNotes,
    int? overallEffort,
    required List<Map<String, dynamic>> sets,
  }) async {
    _setLoading(true);
    try {
      await _repo.logWorkoutDay(
        traineeId: traineeId, workoutDayId: workoutDayId,
        trainedOn: trainedOn, allWeightsPrescribed: allWeightsPrescribed,
        traineeNotes: traineeNotes, overallEffort: overallEffort, sets: sets,
      );
      _setLoading(false);
      return true;
    } catch (e) { _setError(e.toString()); return false; }
  }

  Future<String?> createCustomExercise({
    required String nameEn,
    String? nameAr,
    required String muscleGroup,
    String? equipment,
    String? description,
    String? imageUrl,
    String? videoUrl,
  }) async {
    _setLoading(true);
    try {
      final id = await _repo.createCustomExercise(
        nameEn: nameEn, nameAr: nameAr, muscleGroup: muscleGroup,
        equipment: equipment, descriptionEn: description,
        imageUrl: imageUrl, videoUrl: videoUrl,
      );
      _setLoading(false);
      return id;
    } catch (e) { _setError(e.toString()); return null; }
  }

  Future<String?> uploadExerciseImage(File file) async {
    try { return await _repo.uploadExerciseImage(file); }
    catch (e) { _setError(e.toString()); return null; }
  }

  void clearCurrentProgram() { _currentProgram = null; notifyListeners(); }
}
