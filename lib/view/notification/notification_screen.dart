import 'package:fitnessapp/data/models/notification_model.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/providers/notification_provider.dart';
import 'package:fitnessapp/view/platform/support_tickets_screen.dart';
import 'package:fitnessapp/view/support/my_support_tickets_screen.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/chat/chat_list_screen.dart';
import 'package:fitnessapp/view/payment/my_subscription_screen.dart';
import 'package:fitnessapp/view/platform/payment_requests_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = '/NotificationScreen';
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<NotificationProvider>();
      await provider.loadFirst();
      await provider.markAllRead();
    });
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<NotificationProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final notif = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: colors.listTile,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset('assets/icons/back_icon.png',
                width: 15, height: 15, fit: BoxFit.contain),
          ),
        ),
        title: Text(l10n.notificationsTitle,
            style: TextStyle(
                color: colors.fg, fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          if (notif.unreadCount > 0)
            InkWell(
              onTap: () => notif.markAllRead(),
              child: Container(
                margin: const EdgeInsets.all(8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: colors.listTile,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(l10n.markAllRead,
                    style: const TextStyle(
                        color: AppColors.primaryColor1,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
      body: notif.loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor1))
          : notif.items.isEmpty
              ? _EmptyState(colors: colors)
              : ListView.separated(
                  controller: _scroll,
                  padding: EdgeInsets.fromLTRB(
                      16, 8, 16, MediaQuery.of(context).padding.bottom + 90),
                  itemCount: notif.items.length + (notif.hasMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: colors.divider),
                  itemBuilder: (context, i) {
                    if (i == notif.items.length) {
                      // Load-more indicator
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: notif.loadingMore
                              ? const CircularProgressIndicator(
                                  color: AppColors.primaryColor1,
                                  strokeWidth: 2)
                              : const SizedBox.shrink(),
                        ),
                      );
                    }
                    return _NotifTile(notif: notif.items[i], colors: colors);
                  },
                ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  final dynamic colors;
  const _NotifTile({required this.notif, required this.colors});

  /// Deep-link to the relevant screen based on the notification type.
  void _handleTap(BuildContext context) {
    switch (notif.type) {
      case NotifType.chat:
        Navigator.pushNamed(context, ChatListScreen.routeName);
        break;
      case NotifType.paymentRequest:
        // Platform Owner → review the manual payment request.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentRequestsScreen()),
        );
        break;
      case NotifType.payment:
      case NotifType.subscription:
        // Trainee → their subscription / payment status.
        Navigator.pushNamed(context, MySubscriptionScreen.routeName);
        break;
      case NotifType.support:
        // Owner → all tickets; everyone else → their own tickets.
        final isOwner = context.read<AuthProvider>().isPlatformOwner;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => isOwner
                ? const SupportTicketsScreen()
                : const MySupportTicketsScreen(),
          ),
        );
        break;
      default:
        // No specific destination (workout / nutrition / system).
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTime(notif.createdAt, AppLocalizations.of(context));

    return InkWell(
      onTap: () => _handleTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        color: notif.isRead
            ? null
            : AppColors.primaryColor1.withValues(alpha: 0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient icon bubble
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: notif.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(notif.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notif.title,
                            style: TextStyle(
                                color: colors.fg,
                                fontSize: 14,
                                fontWeight: notif.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700)),
                      ),
                      Text(timeStr,
                          style:
                              TextStyle(color: colors.mutedFg, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(notif.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: colors.subFg, fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            if (!notif.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                    color: AppColors.primaryColor1, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return DateFormat('MMM d').format(dt);
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final dynamic colors;
  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 64, color: colors.mutedFg),
          const SizedBox(height: 16),
          Text(l10n.noNotificationsYet,
              style: TextStyle(
                  color: colors.subFg,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(l10n.notificationEmptyHint,
              style: TextStyle(color: colors.mutedFg, fontSize: 13)),
        ],
      ),
    );
  }
}
