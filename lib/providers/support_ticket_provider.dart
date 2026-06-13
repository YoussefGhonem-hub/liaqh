import 'package:flutter/material.dart';
import '../data/models/support_ticket_models.dart';
import '../data/repositories/support_ticket_repository.dart';

class SupportTicketProvider extends ChangeNotifier {
  final SupportTicketRepository _repo;
  SupportTicketProvider(this._repo);

  List<SupportTicketModel> tickets = []; // admin list
  List<SupportTicketModel> myTickets = [];
  SupportTicketDetailModel? detail; // open conversation
  bool loading = false;
  bool detailLoading = false;
  bool submitting = false;
  String? error;

  Future<void> loadDetail(String id) async {
    detailLoading = true;
    notifyListeners();
    try {
      detail = await _repo.detail(id);
    } catch (e) {
      error = e.toString();
    } finally {
      detailLoading = false;
      notifyListeners();
    }
  }

  Future<bool> postMessage(String id, String body) async {
    try {
      await _repo.postMessage(id, body);
      await loadDetail(id);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> close(String id) async {
    try {
      await _repo.close(id);
      await loadDetail(id);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAll({String? status}) async {
    loading = true;
    notifyListeners();
    try {
      tickets = await _repo.list(status: status);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMine() async {
    loading = true;
    notifyListeners();
    try {
      myTickets = await _repo.mine();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> create(String subject, String message) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _repo.create(subject: subject, message: message);
      await loadMine();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

}
