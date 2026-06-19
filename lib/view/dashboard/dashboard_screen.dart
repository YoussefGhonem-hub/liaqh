import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/common_widgets/user_avatar.dart';
import 'package:fitnessapp/providers/chat_provider.dart';
import 'package:fitnessapp/providers/language_provider.dart';
import 'package:fitnessapp/providers/theme_provider.dart';
import 'package:fitnessapp/view/chat/chat_list_screen.dart';
import 'package:fitnessapp/view/notification/notification_screen.dart';
import 'package:fitnessapp/providers/notification_provider.dart';
import 'package:fitnessapp/providers/payment_provider.dart';
import 'package:fitnessapp/providers/payment_methods_provider.dart';
import 'package:fitnessapp/utils/liaqh_icon.dart';
import 'package:fitnessapp/providers/dashboard_provider.dart';
import 'package:fitnessapp/view/payment/subscription_lock_view.dart';
import 'package:fitnessapp/view/payment/my_subscription_screen.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/login/login_screen.dart';
import 'package:fitnessapp/view/profile/settings_screen.dart';
import 'package:fitnessapp/view/profile/user_profile.dart';
import 'package:fitnessapp/view/profile/my_details_screen.dart';
import 'package:fitnessapp/view/trainees/add_trainee_screen.dart';
import 'package:fitnessapp/view/trainees/trainees_screen.dart';
import 'package:fitnessapp/view/platform/platform_overview_screen.dart';
import 'package:fitnessapp/view/platform/gyms_list_screen.dart';
import 'package:fitnessapp/view/platform/platform_revenue_screen.dart';
import 'package:fitnessapp/view/platform/platform_users_screen.dart';
import 'package:fitnessapp/view/platform/payment_requests_screen.dart';
import 'package:fitnessapp/view/platform/payment_methods_management_screen.dart';
import 'package:fitnessapp/view/support/my_support_tickets_screen.dart';
import 'package:fitnessapp/view/workout/workout_templates_screen.dart';
import 'package:fitnessapp/view/guide/coach_guide_screen.dart';
import 'package:fitnessapp/view/guide/app_tour_overlay.dart';
import 'package:fitnessapp/view/coaching/needs_attention_screen.dart';
import 'package:fitnessapp/view/coaching/leaderboard_screen.dart';
import 'package:fitnessapp/view/coaching/broadcast_screen.dart';
import 'package:fitnessapp/view/platform/support_tickets_screen.dart';
import 'package:fitnessapp/view/gym_admin/gym_admin_dashboard_screen.dart';
import 'package:fitnessapp/view/gym_admin/coaches_screen.dart';
import 'package:fitnessapp/view/platform/platform_coaches_screen.dart';
import 'package:fitnessapp/view/platform/send_announcement_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/home_screen.dart';

class DashboardScreen extends StatefulWidget {
  static String routeName = "/DashboardScreen";
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int selectTab = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _subPromptShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();

      // Load notifications so the bell badge shows unread count after login.
      context.read<NotificationProvider>().loadFirst();

      // Platform Owner: pending payment-request count for the Requests badge.
      if (_isPlatformOwner) {
        context.read<PaymentMethodsProvider>().loadPendingCount();
      }

      // Start the chat unread listener so the message badge appears right
      // after login (fresh logins don't pass through the splash AuthGate).
      final auth = context.read<AuthProvider>();
      final user = auth.currentUser;
      if (user != null) {
        context
            .read<ChatProvider>()
            .listenConversations(user.userId, auth.isCoach);
      }

      // Trainees: load subscription gating flags, then prompt if needed.
      if (auth.isTrainee) {
        context.read<PaymentProvider>().loadAccess().then((_) {
          if (mounted) _maybeShowSubscribePrompt();
        });
      }

      // First-time welcome tour (shown once after register / first open).
      AppTour.maybeShow(context, isCoach: auth.isCoach || auth.isGymAdmin);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;

    // Refresh notifications so the bell badge stays current.
    context.read<NotificationProvider>().loadFirst();
    if (_isPlatformOwner) {
      context.read<PaymentMethodsProvider>().loadPendingCount();
    }

    // Re-check subscription access whenever the app returns to the foreground,
    // so an expired/cancelled subscription revokes access immediately.
    if (context.read<AuthProvider>().isTrainee) {
      context.read<PaymentProvider>().loadAccess().then((_) {
        if (mounted) _maybeShowSubscribePrompt();
      });
    }
  }

  /// One-time dismissible popup nudging an unsubscribed trainee to subscribe.
  void _maybeShowSubscribePrompt() {
    if (_subPromptShown) return;
    final pp = context.read<PaymentProvider>();
    if (!pp.accessLoaded || !pp.premiumLocked) return;
    _subPromptShown = true;

    final colors = context.colors;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => Dialog(
        backgroundColor: colors.card,
        insetPadding: const EdgeInsets.symmetric(horizontal: 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: Icon(Icons.close_rounded, color: colors.subFg),
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primaryG),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context).membershipPaymentDue,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: colors.fg,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).payCoachUnlockMessage,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: colors.subFg, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, ChatListScreen.routeName);
                  },
                  icon: const Icon(Icons.chat_bubble_rounded, size: 20),
                  label: Text(AppLocalizations.of(context).messageCoach,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor1,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(context).maybeLater,
                    style: TextStyle(color: colors.subFg)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool get _isStaff {
    final auth = context.read<AuthProvider>();
    return auth.isCoach || auth.isGymAdmin;
  }

  bool get _isGymAdmin => context.read<AuthProvider>().isGymAdmin;

  bool get _isPlatformOwner => context.read<AuthProvider>().isPlatformOwner;

  /// Trainee has not subscribed and premium content should be locked.
  bool get _premiumLocked {
    final auth = context.read<AuthProvider>();
    if (!auth.isTrainee) return false;
    final pp = context.read<PaymentProvider>();
    return pp.accessLoaded && pp.premiumLocked;
  }

  void _openWorkouts() {
    if (_premiumLocked) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
                title: Text(AppLocalizations.of(context).dashWorkouts)),
            body: SafeArea(
              child: SubscriptionLockView(
                blocking: false,
                // Unlocked while viewing the lock → replace it with the workout.
                onSubscribed: () {
                  if (!mounted) return;
                  setState(() {});
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const MyDetailsScreen(initialTab: 3),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MyDetailsScreen(initialTab: 3),
        ),
      );
    }
  }

  List<Widget> get _tabs {
    if (_isPlatformOwner) {
      return const [
        PlatformOverviewScreen(),
        GymsListScreen(),
        PlatformRevenueScreen(),
        UserProfile(),
      ];
    }
    if (_isGymAdmin) {
      return const [
        GymAdminDashboardScreen(),
        CoachesScreen(),
        UserProfile(),
      ];
    }
    if (_isStaff) {
      return [
        const HomeScreen(),
        const TraineesScreen(),
        const UserProfile(),
      ];
    }
    // Trainee: Home + rich "My Details" (profile, workout, nutrition, inbody…)
    return [
      const HomeScreen(),
      const MyDetailsScreen(),
    ];
  }

  void _openDrawer() {
    final isRtl = context.read<LanguageProvider>().isArabic;
    if (isRtl) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  void _closeDrawer() {
    final isRtl = context.read<LanguageProvider>().isArabic;
    if (isRtl) {
      _scaffoldKey.currentState?.closeEndDrawer();
    } else {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  // ── Role-aware bottom nav items ─────────────────────────────────────────────
  // Center (raised orange button) = Home. Each role provides 2 left + 2 right
  // items (4 total) that sit around the notch. Icons are unchanged.
  ({List<_BarItem> left, List<_BarItem> right}) _navItems(
      int chatUnread, int notifUnread, int pendingRequests) {
    final l10n = AppLocalizations.of(context);
    final more = _BarItem(
      icon: Icons.more_horiz_rounded,
      label: l10n.tabMore,
      selected: false,
      onTap: _openDrawer,
    );
    final alerts = _BarItem(
      icon: Icons.notifications_rounded,
      label: l10n.tabAlerts,
      badge: notifUnread,
      selected: false,
      onTap: () => Navigator.pushNamed(context, NotificationScreen.routeName),
    );
    final chat = _BarItem(
      icon: Icons.chat_bubble_rounded,
      label: l10n.tabChat,
      badge: chatUnread,
      selected: false,
      onTap: () => Navigator.pushNamed(context, ChatListScreen.routeName),
    );

    if (_isPlatformOwner) {
      return (
        left: [
          _BarItem(
              icon: Icons.fact_check_rounded,
              label: l10n.tabRequests,
              badge: pendingRequests,
              selected: false,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PaymentRequestsScreen())).then((_) {
                if (mounted) {
                  context.read<PaymentMethodsProvider>().loadPendingCount();
                }
              })),
          alerts,
        ],
        right: [
          _BarItem(
              icon: Icons.support_agent_rounded,
              label: l10n.tabSupport,
              selected: false,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SupportTicketsScreen()))),
          more,
        ],
      );
    }
    if (_isGymAdmin) {
      return (
        left: [
          _BarItem(
              icon: Icons.sports_rounded,
              label: l10n.dashCoaches,
              selected: selectTab == 1,
              onTap: () => setState(() => selectTab = 1)),
          alerts,
        ],
        right: [chat, more],
      );
    }
    if (_isStaff) {
      return (
        left: [
          _BarItem(
              icon: Icons.people_alt_rounded,
              label: l10n.dashTrainees,
              selected: selectTab == 1,
              onTap: () => setState(() => selectTab = 1)),
          alerts,
        ],
        right: [chat, more],
      );
    }
    // Trainee
    return (
      left: [
        _BarItem(
            icon: Icons.fitness_center_rounded,
            label: l10n.dashWorkouts,
            selected: false,
            onTap: _openWorkouts),
        alerts,
      ],
      right: [chat, more],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isRtl = context.watch<LanguageProvider>().isArabic;
    final isTrainee = context.read<AuthProvider>().isTrainee;
    final pp = context.watch<PaymentProvider>();
    final chatUnread = context.watch<ChatProvider>().totalUnread;
    final notifUnread = context.watch<NotificationProvider>().unreadCount;
    final pendingRequests =
        _isPlatformOwner ? context.watch<PaymentMethodsProvider>().pendingCount : 0;

    final drawer = _AppDrawer(
      onClose: _closeDrawer,
      onNavigate: (index) {
        setState(() => selectTab = index);
        _closeDrawer();
      },
    );

    // Dashboard + basic pages stay open. Only the premium tab is gated for
    // unsubscribed trainees — and the lock can be closed (back to dashboard).
    List<Widget> tabs = _tabs;
    if (isTrainee && pp.accessLoaded && pp.premiumLocked && tabs.length > 1) {
      tabs = List<Widget>.from(tabs);
      tabs[1] = SubscriptionLockView(
        blocking: false,
        onSubscribed: () => setState(() {}),
        onClose: () => setState(() => selectTab = 0),
      );
    }

    final nav = _navItems(chatUnread, notifUnread, pendingRequests);
    const barColor = Color(0xFF1E1E1E);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.bg,
      // No extendBody → the body sits ABOVE the bar, so nothing is overlapped.
      extendBody: false,
      drawer: isRtl ? null : drawer,
      endDrawer: isRtl ? drawer : null,
      body: IndexedStack(index: selectTab, children: tabs),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _CenterHomeButton(
        selected: selectTab == 0,
        onTap: () => setState(() => selectTab = 0),
      ),
      bottomNavigationBar: BottomAppBar(
        color: barColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 18,
        padding: EdgeInsets.zero,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                Expanded(child: _BarItemWidget(item: nav.left[0])),
                Expanded(child: _BarItemWidget(item: nav.left[1])),
                const SizedBox(width: 68), // gap for the docked center button
                Expanded(child: _BarItemWidget(item: nav.right[0])),
                Expanded(child: _BarItemWidget(item: nav.right[1])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom-bar item model + widgets ───────────────────────────────────────────
class _BarItem {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;
  const _BarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });
}

class _BarItemWidget extends StatelessWidget {
  final _BarItem item;
  const _BarItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.selected ? AppColors.primaryColor1 : Colors.white;
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(item.icon, size: 23, color: color),
              if (item.badge > 0)
                Positioned(
                  right: -8,
                  top: -5,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: item.badge > 9
                          ? BoxShape.rectangle
                          : BoxShape.circle,
                      borderRadius:
                          item.badge > 9 ? BorderRadius.circular(8) : null,
                      border: const Border.fromBorderSide(
                          BorderSide(color: Color(0xFF1E1E1E), width: 1.5)),
                    ),
                    child: Center(
                      child: Text(item.badge > 99 ? '99+' : '${item.badge}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              height: 1)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: color,
              fontWeight: item.selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// The raised orange circular center button (Home).
class _CenterHomeButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  const _CenterHomeButton({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor1.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: AppColors.primaryColor1,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(7),
          child: LiaqhIcon(
            size: 34,
            bgColor: AppColors.primaryColor1,
            avatarColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── App drawer ────────────────────────────────────────────────────────────────
class _AppDrawer extends StatelessWidget {
  final VoidCallback onClose;
  final void Function(int index) onNavigate;
  const _AppDrawer({required this.onClose, required this.onNavigate});

  Future<void> _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    const danger = Color(0xFFEF4444);

    // Capture stable references BEFORE any async gap / closing the drawer,
    // so we never touch a deactivated widget's context afterwards.
    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();
    final rootNav = Navigator.of(context, rootNavigator: true);

    const danger2 = Color(0xFFB91C1C);
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutBack,
        tween: Tween(begin: 0.9, end: 1.0),
        builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
        child: Dialog(
          backgroundColor: colors.card,
          elevation: 24,
          insetPadding: const EdgeInsets.symmetric(horizontal: 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing icon ring
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      danger.withValues(alpha: 0.22),
                      danger.withValues(alpha: 0.04),
                    ]),
                  ),
                  child: Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [danger, danger2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: danger.withValues(alpha: 0.45),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.logOutTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: colors.fg,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.logOutMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: colors.subFg, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.fg,
                            backgroundColor: colors.listTile,
                            side: BorderSide(color: colors.divider),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(l10n.cancel,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [danger, danger2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: danger.withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.pop(ctx, true),
                            child: Center(
                              child: Text(l10n.logOut,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (confirmed != true) return;

    onClose(); // close the drawer now that the dialog is gone
    chat.stopListening(); // stop Firestore watch streams
    await auth.logout();
    rootNav.pushNamedAndRemoveUntil(LoginScreen.routeName, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isCoach = auth.isCoach;
    final isAdmin = user?.role == 'GymAdmin';
    final isPlatformOwner = user?.role == 'PlatformOwner';
    final name = user?.fullName ?? '';
    final role = user?.role ?? '';
    final imagePath = user?.profileImageUrl ?? user?.gymLogoUrl;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      backgroundColor: colors.bg,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 24, 24, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C1714), Color(0xFF2A221E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const LiaqhIcon(
                        size: 36,
                        bgColor: Color(0xFFD97757),
                        avatarColor: Colors.white),
                    const Spacer(),
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                UserAvatar(
                  imageUrl: imagePath,
                  name: name,
                  radius: 28,
                  backgroundColor:
                      AppColors.primaryColor1.withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor1.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(role,
                      style: const TextStyle(
                          color: AppColors.primaryColor1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: Builder(builder: (context) {
              final l10n = AppLocalizations.of(context);
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _DrawerSection(title: l10n.drawerNavigation),
                  _DrawerItem(
                    icon: Icons.home_rounded,
                    label: l10n.navHome,
                    color: AppColors.primaryColor1,
                    onTap: () => onNavigate(0),
                  ),
                  _DrawerItem(
                    icon: Icons.person_rounded,
                    label: l10n.navProfile,
                    color: const Color(0xFF6C63FF),
                    // Profile tab index differs by role:
                    // platform owner = 3, staff = 2, trainee = 1
                    onTap: () => onNavigate(isPlatformOwner
                        ? 3
                        : (isCoach || isAdmin)
                            ? 2
                            : 1),
                  ),
                  if (!isPlatformOwner) _ChatDrawerItem(onClose: onClose),

                  // Trainee: quick access to their subscription details.
                  if (!isCoach && !isAdmin && !isPlatformOwner)
                    _DrawerItem(
                      icon: Icons.workspace_premium_rounded,
                      label: l10n.drawerMySubscription,
                      color: AppColors.primaryColor1,
                      onTap: () {
                        onClose();
                        Navigator.pushNamed(
                            context, MySubscriptionScreen.routeName);
                      },
                    ),

                  if (isPlatformOwner) ...[
                    _DrawerSection(title: l10n.dashPlatform),
                    _DrawerItem(
                      icon: Icons.dashboard_rounded,
                      label: l10n.drawerOverview,
                      color: AppColors.primaryColor1,
                      onTap: () => onNavigate(0),
                    ),
                    _DrawerItem(
                      icon: Icons.fitness_center_rounded,
                      label: l10n.drawerManageGyms,
                      color: const Color(0xFF10B981),
                      onTap: () => onNavigate(1),
                    ),
                    _DrawerItem(
                      icon: Icons.payments_rounded,
                      label: l10n.dashRevenue,
                      color: AppColors.successColor,
                      onTap: () => onNavigate(2),
                    ),
                    _DrawerItem(
                      icon: Icons.group_rounded,
                      label: l10n.drawerAllUsers,
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        onClose();
                        Navigator.pushNamed(
                            context, PlatformUsersScreen.routeName);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.sports_rounded,
                      label: l10n.drawerAllCoaches,
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        onClose();
                        Navigator.pushNamed(
                            context, PlatformCoachesScreen.routeName);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.tune_rounded,
                      label: l10n.dashPaymentMethods,
                      color: const Color(0xFF06B6D4),
                      onTap: () {
                        onClose();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const PaymentMethodsManagementScreen()));
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.campaign_rounded,
                      label: l10n.drawerSendAnnouncement,
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        onClose();
                        Navigator.pushNamed(
                            context, SendAnnouncementScreen.routeName);
                      },
                    ),
                  ],

                  // Coach (not gym admin): their own trainees.
                  if (isCoach) ...[
                    _DrawerSection(title: l10n.drawerCoachActions),
                    _DrawerItem(
                      icon: Icons.people_alt_rounded,
                      label: l10n.navMyTrainees,
                      color: const Color(0xFF10B981),
                      onTap: () => onNavigate(1),
                    ),
                    // Only individual coaches may create their own trainees.
                    if (auth.canCreateTrainees)
                      _DrawerItem(
                        icon: Icons.person_add_rounded,
                        label: l10n.navAddNewTrainee,
                        color: AppColors.primaryColor1,
                        onTap: () {
                          onClose();
                          Navigator.pushNamed(
                              context, AddTraineeScreen.routeName);
                        },
                      ),
                    // Reusable workout templates the coach assigns to trainees.
                    _DrawerItem(
                      icon: Icons.assignment_rounded,
                      label: l10n.workoutTemplates,
                      color: const Color(0xFF6366F1),
                      onTap: () {
                        onClose();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const WorkoutTemplatesScreen()));
                      },
                    ),
                    // Step-by-step guide for coaches.
                    _DrawerItem(
                      icon: Icons.menu_book_rounded,
                      label: l10n.coachGuide,
                      color: AppColors.primaryColor1,
                      onTap: () {
                        onClose();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CoachGuideScreen()));
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.warning_amber_rounded,
                      label: l10n.needsAttention,
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        onClose();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NeedsAttentionScreen()));
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.leaderboard_rounded,
                      label: l10n.leaderboard,
                      color: const Color(0xFF10B981),
                      onTap: () {
                        onClose();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LeaderboardScreen()));
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.campaign_rounded,
                      label: l10n.broadcast,
                      color: const Color(0xFF6366F1),
                      onTap: () {
                        onClose();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BroadcastScreen()));
                      },
                    ),
                  ],

                  // Gym Admin management. ("Home" above already opens the
                  // dashboard tab, so no duplicate Dashboard item here.)
                  if (isAdmin) ...[
                    _DrawerSection(title: l10n.drawerAdmin),
                    _DrawerItem(
                      icon: Icons.sports_rounded,
                      label: l10n.dashCoaches,
                      color: const Color(0xFF8B5CF6),
                      onTap: () => onNavigate(1),
                    ),
                    _DrawerItem(
                      icon: Icons.menu_book_rounded,
                      label: l10n.coachGuide,
                      color: AppColors.primaryColor1,
                      onTap: () {
                        onClose();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CoachGuideScreen()));
                      },
                    ),
                  ],

                  // Support tickets — every non-owner role can open a ticket
                  // and chat with the Platform Owner. (Owners manage tickets
                  // from their own Support screen in the bottom bar.)
                  if (!isPlatformOwner)
                    _DrawerItem(
                      icon: Icons.support_agent_rounded,
                      label: l10n.tabSupport,
                      color: const Color(0xFF06B6D4),
                      onTap: () {
                        onClose();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const MySupportTicketsScreen()));
                      },
                    ),

                  _DrawerSection(title: l10n.drawerGeneral),
                  _DrawerToggleItem(
                    icon: Icons.dark_mode_rounded,
                    iconOff: Icons.light_mode_rounded,
                    label: l10n.darkMode,
                    color: const Color(0xFF6C63FF),
                    value: context.watch<ThemeProvider>().isDark,
                    onChanged: (_) => context.read<ThemeProvider>().toggle(),
                  ),
                  _DrawerToggleItem(
                    icon: Icons.language_rounded,
                    iconOff: Icons.language_rounded,
                    label: l10n.languageToggle,
                    color: const Color(0xFF3B82F6),
                    value: context.watch<LanguageProvider>().isArabic,
                    onChanged: (_) =>
                        context.read<LanguageProvider>().toggleLanguage(),
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: l10n.navSettings,
                    color: colors.subFg,
                    onTap: () {
                      onClose();
                      Navigator.pushNamed(context, SettingsScreen.routeName);
                    },
                  ),
                ],
              );
            }),
          ),

          // Logout
          Builder(builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 0, 20, MediaQuery.of(context).padding.bottom + 20),
              child: GestureDetector(
                onTap: () => _logout(context),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 10),
                      Text(l10n.logOut,
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  const _DrawerSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(title.toUpperCase(),
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: context.colors.mutedFg)),
    );
  }
}

class _DrawerToggleItem extends StatelessWidget {
  final IconData icon;
  final IconData iconOff;
  final String label;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _DrawerToggleItem({
    required this.icon,
    required this.iconOff,
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(value ? icon : iconOff, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: colors.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              width: 46,
              height: 26,
              decoration: BoxDecoration(
                color: value
                    ? AppColors.primaryColor1.withValues(alpha: 0.85)
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _DrawerItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: colors.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: colors.mutedFg),
          ],
        ),
      ),
    );
  }
}

// ── Chat drawer item with live unread badge ───────────────────────────────────
class _ChatDrawerItem extends StatelessWidget {
  final VoidCallback onClose;
  const _ChatDrawerItem({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unread = context.watch<ChatProvider>().totalUnread;
    return InkWell(
      onTap: () {
        onClose();
        Navigator.pushNamed(context, ChatListScreen.routeName);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryColor1.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.chat_bubble_rounded,
                  color: AppColors.primaryColor1, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(AppLocalizations.of(context).navMessages,
                  style: TextStyle(
                      color: colors.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$unread',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              )
            else
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: colors.mutedFg),
          ],
        ),
      ),
    );
  }
}
