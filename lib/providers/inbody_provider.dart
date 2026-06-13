import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/inbody_models.dart';
import '../data/repositories/inbody_repository.dart';

class InBodyProvider extends ChangeNotifier {
  final InBodyRepository _repo;
  InBodyProvider(this._repo);

  List<InBodyMeasurement> _history = [];
  bool _loading = false;
  String? _error;

  List<InBodyMeasurement> get history => _history;
  bool get loading => _loading;
  String? get error => _error;

  InBodyMeasurement? get latest => _history.isNotEmpty ? _history.first : null;

  Future<void> loadHistory(String traineeId) async {
    _setLoading(true);
    try {
      _history = await _repo.getHistory(traineeId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> addMeasurement(AddInBodyRequest req) async {
    _setLoading(true);
    try {
      await _repo.addMeasurement(req);
      await loadHistory(req.traineeId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<String?> uploadScan(File file, String traineeId) async {
    try {
      return await _repo.uploadScan(file, traineeId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  void clear() {
    _history = [];
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v; _error = null; notifyListeners();
  }

  void _setError(String msg) {
    _error = msg; _loading = false; notifyListeners();
  }
}
