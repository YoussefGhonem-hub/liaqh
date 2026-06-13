import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationRepository {
  final ApiService _api;
  NotificationRepository(this._api);

  Future<NotificationsPage> getNotifications(int page, {int pageSize = 20}) async {
    final res = await _api.get('/notifications',
        params: {'page': page, 'pageSize': pageSize});
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
    return NotificationsPage(
      items: items,
      unreadCount: data['unreadCount'] as int,
      hasMore: data['hasMore'] as bool,
    );
  }

  Future<void> markAllRead() => _api.patch('/notifications/mark-read');

  Future<void> saveFcmToken(String token) =>
      _api.patch('/notifications/fcm-token', data: {'token': token});
}

class NotificationsPage {
  final List<AppNotification> items;
  final int unreadCount;
  final bool hasMore;
  const NotificationsPage(
      {required this.items, required this.unreadCount, required this.hasMore});
}
