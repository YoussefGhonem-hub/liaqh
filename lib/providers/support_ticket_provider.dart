import 'package:flutter/material.dart';
import '../data/models/support_ticket_models.dart';
import '../data/repositories/support_ticket_repository.dart';

class SupportTicketProvider extends ChangeNotifier {
  final SupportTicketRepository _repo;
  SupportTicketProvider(this._repo);

  static const _pageSize = 20;

  List<SupportTicketModel> tickets = []; // admin list
  List<SupportTicketModel> myTickets = [];
  SupportTicketDetailModel? detail; // open conversation
  bool loading = false;
  bool detailLoading = false;
  bool submitting = false;
  String? error;

  // Pagination state (separate for the owner "all" list and "mine" list).
  bool loadingMore = false;
  bool _allHasMore = false;
  int _allPage = 1;
  String? _allStatus;
  bool _mineHasMore = false;
  int _minePage = 1;
  bool get allHasMore => _allHasMore;
  bool get mineHasMore => _mineHasMore;

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

  Future<bool> editMessage(
      String ticketId, String messageId, String body) async {
    try {
      await _repo.editMessage(messageId, body);
      await loadDetail(ticketId);
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
    _allPage = 1;
    _allStatus = status;
    notifyListeners();
    try {
      final res = await _repo.list(status: status, page: 1, pageSize: _pageSize);
      tickets = res.items;
      _allHasMore = res.hasNextPage;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreAll() async {
    if (loadingMore || !_allHasMore || loading) return;
    loadingMore = true;
    notifyListeners();
    try {
      final res = await _repo.list(
          status: _allStatus, page: _allPage + 1, pageSize: _pageSize);
      tickets = [...tickets, ...res.items];
      _allPage += 1;
      _allHasMore = res.hasNextPage;
    } catch (_) {}
    loadingMore = false;
    notifyListeners();
  }

  Future<void> loadMine() async {
    loading = true;
    _minePage = 1;
    notifyListeners();
    try {
      final res = await _repo.mine(page: 1, pageSize: _pageSize);
      myTickets = res.items;
      _mineHasMore = res.hasNextPage;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreMine() async {
    if (loadingMore || !_mineHasMore || loading) return;
    loadingMore = true;
    notifyListeners();
    try {
      final res = await _repo.mine(page: _minePage + 1, pageSize: _pageSize);
      myTickets = [...myTickets, ...res.items];
      _minePage += 1;
      _mineHasMore = res.hasNextPage;
    } catch (_) {}
    loadingMore = false;
    notifyListeners();
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
