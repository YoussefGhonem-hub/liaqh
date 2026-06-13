import 'package:flutter/material.dart';
import '../data/models/trainee_models.dart';
import '../data/repositories/trainee_repository.dart';

class TraineeProvider extends ChangeNotifier {
  final TraineeRepository _repo;
  TraineeProvider(this._repo);

  List<TraineeSummary> _trainees = [];
  bool _loading = false;
  String? _error;

  List<TraineeSummary> get trainees => _trainees;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadTrainees() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _trainees = await _repo.getMyTrainees();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> addTrainee(CreateTraineeRequest req) async {
    await _repo.createTrainee(req); // let exceptions propagate to the UI
    await loadTrainees();
  }
}
