import 'package:flutter/foundation.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo;
  NotificationProvider(this._repo);

  List<AppNotification> _items = [];
  int _unreadCount = 0;
  bool _hasMore = true;
  bool _loading = false;
  bool _loadingMore = false;
  int _page = 1;

  List<AppNotification> get items => _items;
  int get unreadCount => _unreadCount;
  bool get hasMore => _hasMore;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;

  Future<void> loadFirst() async {
    if (_loading) return;
    _loading = true;
    _page = 1;
    notifyListeners();
    try {
      final page = await _repo.getNotifications(1);
      _items = page.items;
      _unreadCount = page.unreadCount;
      _hasMore = page.hasMore;
      _page = 2;
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final page = await _repo.getNotifications(_page);
      _items = [..._items, ...page.items];
      _unreadCount = page.unreadCount;
      _hasMore = page.hasMore;
      _page++;
    } catch (_) {}
    _loadingMore = false;
    notifyListeners();
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    _unreadCount = 0;
    _items = _items.map((n) => AppNotification(
      id: n.id, type: n.type, title: n.title, body: n.body,
      conversationId: n.conversationId, senderId: n.senderId,
      isRead: true, createdAt: n.createdAt,
    )).toList();
    notifyListeners();
  }

  Future<void> saveFcmToken(String token) => _repo.saveFcmToken(token);

  void setUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }
}
