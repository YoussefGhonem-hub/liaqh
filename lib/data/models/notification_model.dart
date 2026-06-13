import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';

/// Notification type constants
class NotifType {
  static const chat = 'chat';
  static const workout = 'workout';
  static const nutrition = 'nutrition';
  static const subscription = 'subscription';
  static const payment = 'payment';
  static const paymentRequest = 'payment_request';
  static const support = 'support';
  static const inbody = 'inbody';
  static const progress = 'progress';
  static const system = 'system';
}

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? conversationId;
  final String? senderId;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.conversationId,
    this.senderId,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      type: d['type'] ?? NotifType.system,
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      conversationId: d['conversationId'],
      senderId: d['senderId'],
      referenceId: d['referenceId'],
      isRead: d['isRead'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> j) {
    return AppNotification(
      id: j['id'] as String? ?? '',
      type: j['type'] as String? ?? NotifType.system,
      title: j['title'] as String? ?? '',
      body: j['body'] as String? ?? '',
      conversationId: j['conversationId'] as String?,
      senderId: j['senderId'] as String?,
      referenceId: j['referenceId'] as String?,
      isRead: j['isRead'] as bool? ?? false,
      createdAt: _parseServerTime(j['createdAt']),
    );
  }

  /// Server timestamps are UTC. If the string has no timezone marker, treat it
  /// as UTC (not local) so relative times like "5m ago" are correct. Returns a
  /// local DateTime so display/formatting uses the device timezone.
  static DateTime _parseServerTime(dynamic value) {
    if (value == null) return DateTime.now();
    var s = value.toString();
    final hasZone =
        s.endsWith('Z') || RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(s);
    if (!hasZone) s = '${s}Z';
    return DateTime.parse(s).toLocal();
  }

  IconData get icon {
    switch (type) {
      case NotifType.chat:
        return Icons.chat_bubble_rounded;
      case NotifType.workout:
        return Icons.fitness_center_rounded;
      case NotifType.nutrition:
        return Icons.restaurant_rounded;
      case NotifType.subscription:
        return Icons.card_membership_rounded;
      case NotifType.payment:
        return Icons.account_balance_wallet_rounded;
      case NotifType.paymentRequest:
        return Icons.fact_check_rounded;
      case NotifType.support:
        return Icons.support_agent_rounded;
      case NotifType.inbody:
        return Icons.monitor_weight_rounded;
      case NotifType.progress:
        return Icons.photo_library_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  List<Color> get gradientColors {
    switch (type) {
      case NotifType.chat:
        return AppColors.primaryG;
      case NotifType.workout:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
      case NotifType.nutrition:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case NotifType.subscription:
      case NotifType.payment:
      case NotifType.paymentRequest:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      default:
        return [const Color(0xFF64748B), const Color(0xFF475569)];
    }
  }
}
