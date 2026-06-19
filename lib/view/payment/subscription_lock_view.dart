import 'dart:async';

import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/data/models/chat_models.dart';
import 'package:fitnessapp/data/repositories/trainee_repository.dart';
import 'package:fitnessapp/data/services/api_service.dart';
import 'package:fitnessapp/data/services/chat_service.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/providers/chat_provider.dart';
import 'package:fitnessapp/providers/payment_provider.dart';
import 'package:fitnessapp/providers/payment_methods_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/chat/chat_room_screen.dart';
import 'package:fitnessapp/view/login/login_screen.dart';
import 'package:fitnessapp/view/payment/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A full-screen "subscription required / locked" view.
/// - [blocking] true → hard gate (whole app); shows a Logout action, no back.
/// - [blocking] false → soft gate over premium content; user can navigate away.
/// On a successful checkout it reloads access and calls [onSubscribed].
class SubscriptionLockView extends StatefulWidget {
  final bool blocking;
  final String title;
  final String message;
  final VoidCallback? onSubscribed;

  /// When provided, a close (✕) button is shown that calls this — lets the
  /// trainee dismiss the prompt and go back to the dashboard / basic pages.
  final VoidCallback? onClose;

  const SubscriptionLockView({
    Key? key,
    required this.blocking,
    this.title = 'Membership payment due',
    this.message =
        'Your membership isn\'t active. Please pay your coach to unlock your '
        'workouts, meals, InBody tracking and more. Message your coach below '
        'to arrange payment.',
    this.onSubscribed,
    this.onClose,
  }) : super(key: key);

  @override
  State<SubscriptionLockView> createState() => _SubscriptionLockViewState();
}

class _SubscriptionLockViewState extends State<SubscriptionLockView>
    with WidgetsBindingObserver {
  Timer? _poll;
  bool _unlockedNotified = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    // Poll while the trainee is on the lock screen so that the moment the coach
    // marks the period paid (or the admin approves a transfer), the app unlocks
    // on its own — no need to leave and come back.
    _poll = Timer.periodic(const Duration(seconds: 6), (_) => _refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from chatting with / paying the coach → re-check immediately.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final pp = context.read<PaymentProvider>();
    await pp.loadAccess();
    if (mounted) {
      await context.read<PaymentMethodsProvider>().loadMyRequests();
    }
    // Both payments satisfied → notify once so the host can dismiss the lock
    // and reveal the real content.
    if (mounted && !_unlockedNotified && pp.paidPlatform && pp.paidCoach) {
      _unlockedNotified = true;
      _poll?.cancel();
      widget.onSubscribed?.call();
    }
  }

  /// Open the payment-method picker (Paddle / InstaPay / Wallet) to pay the
  /// platform directly.
  Future<void> _payPlatform(BuildContext context) async {
    final paid = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
    );
    if (!context.mounted) return;
    // Refresh both access (Paddle) and pending manual requests (InstaPay/Wallet).
    await context.read<PaymentProvider>().loadAccess();
    if (context.mounted) {
      await context.read<PaymentMethodsProvider>().loadMyRequests();
    }
    if (paid == true) widget.onSubscribed?.call();
  }

  /// Open (or create) the chat with the trainee's coach so they can arrange
  /// payment directly.
  Future<void> _messageCoach(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();
    final nav = Navigator.of(context);
    final user = auth.currentUser;
    if (user == null) return;

    try {
      final me = await TraineeRepository(context.read<ApiService>())
          .getMyProfile();
      final coachUserId = me.coachUserId;
      if (coachUserId == null || coachUserId.isEmpty) {
        messenger.showSnackBar(SnackBar(
            content: Text(l10n.noCoachAssigned)));
        return;
      }
      final coachName = me.coachName ?? l10n.chatCoach;

      final conv = ChatConversation(
        id: ChatService.convId(coachUserId, user.userId),
        coachId: coachUserId,
        traineeId: user.userId,
        coachName: coachName,
        traineeName: user.fullName,
        gymId: user.gymId,
        lastMessage: '',
        lastMessageAt: DateTime.now(),
        unreadCoach: 0,
        unreadTrainee: 0,
      );

      try {
        await chat.openOrCreateConversation(
          coachId: coachUserId,
          traineeId: user.userId,
          coachName: coachName,
          traineeName: user.fullName,
          gymId: user.gymId,
        );
      } catch (_) {/* open the room anyway */}

      nav.pushNamed(ChatRoomScreen.routeName, arguments: conv);
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text('${l10n.couldNotOpenChat}: $e'),
          backgroundColor: AppColors.errorColor));
    }
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.routeName, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final pp = context.watch<PaymentProvider>();
    final pmProvider = context.watch<PaymentMethodsProvider>();
    final paidPlatform = pp.paidPlatform;
    final paidCoach = pp.paidCoach;
    // A submitted InstaPay/Wallet payment awaiting Platform Owner approval.
    final pendingPlatform = !paidPlatform &&
        pmProvider.myRequests.any((r) => r.isPending);

    final effectiveTitle = paidPlatform && !paidCoach
        ? l10n.lockOneStepPayCoach
        : paidCoach && !paidPlatform
            ? l10n.lockOneStepSubscribe
            : l10n.membershipPaymentDue;
    final effectiveMessage = pendingPlatform
        ? l10n.lockPendingMsg
        : paidPlatform && !paidCoach
            ? l10n.lockPaidPlatformMsg
            : paidCoach && !paidPlatform
                ? l10n.lockPaidCoachMsg
                : l10n.lockBothMsg;

    return Container(
      color: colors.bg,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            24, 12, 24, MediaQuery.of(context).padding.bottom + 24),
        children: [
          // Close (✕) — dismiss and return to dashboard / basic pages.
          if (widget.onClose != null)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: widget.onClose,
                icon: Icon(Icons.close_rounded, color: colors.subFg),
                tooltip: l10n.closeLabel,
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryG,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor1.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 48),
            ),
          ),
          const SizedBox(height: 24),
          Text(effectiveTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: colors.fg, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(effectiveMessage,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: colors.subFg, fontSize: 14, height: 1.5)),
          const SizedBox(height: 24),

          // Step 1 — Platform subscription (Paddle / InstaPay / Wallet).
          _PaymentStep(
            index: 1,
            title: l10n.subscribeToPlatform,
            subtitle: l10n.payByCardInstaPayWallet,
            done: paidPlatform,
            pending: pendingPlatform,
            pendingLabel: l10n.pendingAdminApproval,
            actionLabel: l10n.payPlatform,
            actionIcon: Icons.account_balance_wallet_rounded,
            onAction: () => _payPlatform(context),
            colors: colors,
          ),
          const SizedBox(height: 12),
          // Step 2 — Coach payment (approved by the coach).
          _PaymentStep(
            index: 2,
            title: l10n.payYourCoach,
            subtitle: l10n.cashToCoachHint,
            done: paidCoach,
            actionLabel: l10n.messageCoach,
            actionIcon: Icons.chat_bubble_rounded,
            onAction: () => _messageCoach(context),
            colors: colors,
          ),

          if (widget.blocking) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout_rounded,
                    size: 18, color: Color(0xFFEF4444)),
                label: Text(l10n.logOut,
                    style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}

/// One required payment step — shows a green "Paid" state or an action button.
class _PaymentStep extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final bool done;
  final bool pending;
  final String? pendingLabel;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;
  final dynamic colors;

  const _PaymentStep({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.done,
    this.pending = false,
    this.pendingLabel,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final AppThemeColors c = colors as AppThemeColors;
    // accent: green when done, amber when pending, orange otherwise.
    final accent = done
        ? AppColors.successColor
        : pending
            ? AppColors.warningColor
            : AppColors.primaryColor1;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: done ? 0.5 : 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.successColor, size: 20)
                    : pending
                        ? const Icon(Icons.hourglass_top_rounded,
                            color: AppColors.warningColor, size: 18)
                        : Text('$index',
                            style: const TextStyle(
                                color: AppColors.primaryColor1,
                                fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: c.fg,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700)),
                    Text(
                        done
                            ? l10n.paidLabel
                            : pending
                                ? (pendingLabel ?? l10n.pendingApproval)
                                : subtitle,
                        style: TextStyle(
                            color: done || pending ? accent : c.subFg,
                            fontSize: 12,
                            fontWeight: pending
                                ? FontWeight.w600
                                : FontWeight.w400)),
                  ],
                ),
              ),
            ],
          ),
          // Pending → status banner (no action). Not paid & not pending → button.
          if (pending) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warningColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 16, color: AppColors.warningColor),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payment submitted. Waiting for the admin to approve it (up to 24 hours).',
                      style: TextStyle(
                          color: AppColors.warningColor, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (!done) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon, size: 18),
              label: Text(actionLabel,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor1,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
