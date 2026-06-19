import 'package:flutter/material.dart';
import '../data/models/trainee_models.dart';
import '../data/repositories/trainee_repository.dart';

class TraineeProvider extends ChangeNotifier {
  final TraineeRepository _repo;
  TraineeProvider(this._repo);

  static const _pageSize = 20;

  List<TraineeSummary> _trainees = [];
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  String? _error;

  List<TraineeSummary> get trainees => _trainees;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadTrainees() async {
    _loading = true;
    _error = null;
    _page = 1;
    notifyListeners();
    try {
      final res = await _repo.getMyTrainees(page: 1, pageSize: _pageSize);
      _trainees = res.items;
      _hasMore = res.hasNextPage;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore || _loading) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final res =
          await _repo.getMyTrainees(page: _page + 1, pageSize: _pageSize);
      _trainees = [..._trainees, ...res.items];
      _page += 1;
      _hasMore = res.hasNextPage;
    } catch (_) {
      // keep what we have; user can scroll again to retry
    }
    _loadingMore = false;
    notifyListeners();
  }

  Future<void> addTrainee(CreateTraineeRequest req) async {
    await _repo.createTrainee(req); // let exceptions propagate to the UI
    await loadTrainees();
  }
}
