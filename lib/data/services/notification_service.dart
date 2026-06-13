import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

/// Top-level FCM background handler.
/// FCM automatically shows the notification banner when the app is in the
/// background for notification messages — no manual local-notification call
/// needed here. This handler is for data-only messages or side-effects.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Nothing to do — FCM handles display automatically in background/terminated.
}

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();
  static GlobalKey<NavigatorState>? _navKey;

  static const _channelId = 'liaqh_chat';
  static const _channelName = 'Chat Messages';

  /// User preference (Settings → "Pop-up Notification"). When false, foreground
  /// pop-up banners are suppressed. Persisted in SharedPreferences.
  static bool popupEnabled = true;
  static const _popupPrefKey = 'popup_notifications_enabled';

  static Future<void> loadPopupPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      popupEnabled = prefs.getBool(_popupPrefKey) ?? true;
    } catch (_) {}
  }

  static Future<void> setPopupEnabled(bool value) async {
    popupEnabled = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_popupPrefKey, value);
    } catch (_) {}
  }

  static Future<void> init(
    BuildContext context, {
    GlobalKey<NavigatorState>? navKey,
  }) async {
    _navKey = navKey;
    await loadPopupPref();
    try {
      await _init();
    } catch (e) {
      // FCM/Play Services may be unavailable (e.g. emulator). Non-fatal.
      debugPrint('NotificationService.init skipped: $e');
    }
  }

  static Future<void> _init() async {
    // 1. Request permissions
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 2. Create Android high-importance channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Real-time chat notifications from LIAQH',
        importance: Importance.high,
        playSound: true,
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 3. Initialise local notifications plugin
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalTap,
    );

    // 4. Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 5. Foreground messages — show local banner
    FirebaseMessaging.onMessage.listen(_showLocal);

    // 6. Notification tap: app was in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // 7. Notification tap: app was terminated
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleTap(initial);
  }

  /// Save / refresh the FCM token for the currently logged-in user.
  /// Fails silently — FCM is unavailable on emulators without Google Play
  /// Services, and push is optional (in-app chat uses Firestore directly).
  static Future<void> saveTokenForUser(String userId) async {
    try {
      if (userId.isEmpty) return;
      final token = await _fcm.getToken();
      if (token == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(
              {'fcmToken': token, 'tokenUpdatedAt': FieldValue.serverTimestamp()},
              SetOptions(merge: true));

      // Keep token fresh when FCM rotates it
      _fcm.onTokenRefresh.listen((newToken) {
        FirebaseFirestore.instance.collection('users').doc(userId).set(
            {'fcmToken': newToken, 'tokenUpdatedAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true)).catchError((_) {});
      });
    } catch (e) {
      debugPrint('saveTokenForUser skipped: $e');
    }
  }

  /// Write a notification document to the recipient's notifications collection.
  static Future<void> sendInAppNotification({
    required String recipientId,
    required String title,
    required String body,
    required String type,
    String? conversationId,
    String? senderId,
  }) async {
    if (recipientId.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(recipientId)
        .collection('items')
        .add({
      'type': type,
      'title': title,
      'body': body,
      'conversationId': conversationId,
      'senderId': senderId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Typed helpers ────────────────────────────────────────────────────────

  /// Notify a trainee that a new workout plan was assigned by their coach.
  static Future<void> notifyWorkoutPlanAssigned({
    required String traineeId,
    required String planName,
    required String coachName,
  }) =>
      sendInAppNotification(
        recipientId: traineeId,
        type: NotifType.workout,
        title: 'New Workout Plan 💪',
        body: '$coachName assigned you a new workout plan: $planName',
      );

  /// Notify a trainee that a workout day was added to their plan.
  static Future<void> notifyWorkoutDayAdded({
    required String traineeId,
    required String dayName,
    required String coachName,
  }) =>
      sendInAppNotification(
        recipientId: traineeId,
        type: NotifType.workout,
        title: 'Workout Updated 🏋️',
        body: '$coachName added "$dayName" to your workout plan',
      );

  /// Notify a trainee that a new meal plan was assigned.
  static Future<void> notifyMealPlanAssigned({
    required String traineeId,
    required String planName,
    required String coachName,
  }) =>
      sendInAppNotification(
        recipientId: traineeId,
        type: NotifType.nutrition,
        title: 'New Meal Plan 🥗',
        body: '$coachName assigned you a new nutrition plan: $planName',
      );

  /// Notify a trainee that meals were added/updated in their plan.
  static Future<void> notifyMealPlanUpdated({
    required String traineeId,
    required String coachName,
  }) =>
      sendInAppNotification(
        recipientId: traineeId,
        type: NotifType.nutrition,
        title: 'Meal Plan Updated 🍽️',
        body: '$coachName updated your nutrition plan',
      );

  /// Notify a trainee that their subscription was activated.
  static Future<void> notifySubscriptionActivated({
    required String traineeId,
    required String planName,
  }) =>
      sendInAppNotification(
        recipientId: traineeId,
        type: NotifType.subscription,
        title: 'Subscription Activated ✅',
        body: 'Your "$planName" membership is now active. Let\'s get started!',
      );

  /// Notify a trainee that their membership status changed.
  static Future<void> notifyMembershipStatusChanged({
    required String traineeId,
    required String status,
  }) {
    final (title, body) = switch (status.toLowerCase()) {
      'frozen' => (
          'Membership Frozen ❄️',
          'Your membership has been temporarily frozen.'
        ),
      'cancelled' => (
          'Membership Cancelled',
          'Your membership has been cancelled. Contact your gym for details.'
        ),
      'active' => (
          'Membership Reactivated ✅',
          'Your membership is active again. Welcome back!'
        ),
      _ => (
          'Membership Updated',
          'Your membership status has been updated to: $status'
        ),
    };
    return sendInAppNotification(
      recipientId: traineeId,
      type: NotifType.subscription,
      title: title,
      body: body,
    );
  }

  /// Notify a trainee that their membership was renewed.
  static Future<void> notifyMembershipRenewed({
    required String traineeId,
    required String planName,
  }) =>
      sendInAppNotification(
        recipientId: traineeId,
        type: NotifType.subscription,
        title: 'Membership Renewed 🎉',
        body: 'Your "$planName" membership has been renewed successfully.',
      );

  /// Stream of unread notification count for a user.
  static Stream<int> unreadStream(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// Mark all notifications as read.
  static Future<void> markAllRead(String userId) async {
    final snap = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  static Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('getToken failed: $e');
      return null;
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  static void _showLocal(RemoteMessage message) {
    if (!popupEnabled) return; // user disabled pop-up notifications
    final n = message.notification;
    if (n == null) return;

    _local.show(
      n.hashCode,
      n.title ?? 'New message',
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(n.body ?? ''),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static void _onLocalTap(NotificationResponse response) {
    final conversationId = response.payload;
    if (conversationId != null && conversationId.isNotEmpty) {
      _navKey?.currentState
          ?.pushNamed('/ChatListScreen');
    }
  }

  static void _handleTap(RemoteMessage message) {
    final conversationId = message.data['conversationId'];
    if (conversationId != null && conversationId.isNotEmpty) {
      _navKey?.currentState?.pushNamed('/ChatListScreen');
    }
  }
}
