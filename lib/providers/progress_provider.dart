import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/progress_models.dart';
import '../data/repositories/progress_repository.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _repo;
  ProgressProvider(this._repo);

  List<ProgressEntry> _history = [];
  bool _loading = false;
  bool _saving = false;
  String? _error;

  List<ProgressEntry> get history => _history;
  bool get loading => _loading;
  bool get saving => _saving;
  String? get error => _error;

  Future<void> loadHistory(String traineeId) async {
    _setLoading(true);
    try {
      _history = await _repo.getHistory(traineeId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> addEntry(AddProgressRequest req) async {
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.addEntry(req);
      await loadHistory(req.traineeId);
      _saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _saving = false;
      _setError(e.toString());
      return false;
    }
  }

  Future<String?> uploadPhoto(File file, String traineeId) async {
    try {
      return await _repo.uploadPhoto(file, traineeId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> deleteEntry(String id, String traineeId) async {
    try {
      await _repo.deleteEntry(id);
      _history.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void clear() {
    _history = [];
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _loading = false;
    notifyListeners();
  }
}
