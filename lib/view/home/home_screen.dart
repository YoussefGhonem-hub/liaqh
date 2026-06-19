import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/providers/dashboard_provider.dart';
import 'package:fitnessapp/providers/notification_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/notification/notification_screen.dart';
import 'package:fitnessapp/view/profile/my_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/HomeScreen";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context);
    final user = auth.currentUser;
    final isCoach = auth.isCoach || (user?.role == 'GymAdmin');

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<DashboardProvider>().loadDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).padding.bottom + 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(l10n: l10n, colors: colors),
                const SizedBox(height: 20),
                if (isCoach) ...[
                  _CoachDashboardContent(l10n: l10n, colors: colors),
                ] else ...[
                  _TraineeDashboardContent(l10n: l10n, colors: colors),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final AppLocalizations l10n;
  final dynamic colors;
  const _Header({required this.l10n, required this.colors});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.currentUser?.fullName ?? '';
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeBack,
                style: TextStyle(color: colors.mutedFg, fontSize: 13),
              ),
              Text(
                name,
                style: TextStyle(
                    color: colors.fg,
                    fontSize: 22,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, NotificationScreen.routeName),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8)
                  ],
                ),
                child: Icon(Icons.notifications_rounded,
                    color: colors.subFg, size: 22),
              ),
              if (unread > 0)
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Color(0xFFEF4444), shape: BoxShape.circle),
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text('$unread',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Coach / Admin dashboard content ──────────────────────────────────────────
class _CoachDashboardContent extends StatelessWidget {
  final AppLocalizations l10n;
  final dynamic colors;
  const _CoachDashboardContent({required this.l10n, required this.colors});

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DashboardProvider>();
    final dashboard = dp.dashboard;

    if (dp.loading && dashboard == null) {
      return const Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: LiaqhPageLoader());
    }
    if (dashboard == null) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Icon(Icons.people_alt_outlined, size: 56, color: colors.mutedFg),
            const SizedBox(height: 12),
            Text(l10n.noData,
                style: TextStyle(color: colors.subFg, fontSize: 15)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Analytics ────────────────────────────────────────────────────
        Text(l10n.analyticsTitle,
            style: TextStyle(
                color: colors.fg, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatPill(
                label: l10n.totalTraineesLabel,
                value: '${dashboard.totalTrainees}',
                icon: Icons.people_alt_rounded,
                color: const Color(0xFF3B82F6)),
            const SizedBox(width: 10),
            _StatPill(
                label: l10n.activeTraineesLabel,
                value: '${dashboard.activeTrainees}',
                icon: Icons.bolt_rounded,
                color: AppColors.successColor),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StatPill(
                label: l10n.retentionLabel,
                value: '${dashboard.retentionRate}%',
                icon: Icons.favorite_rounded,
                color: const Color(0xFFEC4899)),
            const SizedBox(width: 10),
            _StatPill(
                label: l10n.newThisMonthLabel,
                value: '${dashboard.newThisMonth}',
                icon: Icons.person_add_alt_1_rounded,
                color: const Color(0xFF6366F1)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StatPill(
                label: l10n.revenueThisMonthLabel,
                value: dashboard.revenueThisMonth.toStringAsFixed(0),
                icon: Icons.payments_rounded,
                color: const Color(0xFF10B981)),
            const SizedBox(width: 10),
            _StatPill(
                label: l10n.workoutsThisWeekLabel,
                value: '${dashboard.workoutsThisWeek}',
                icon: Icons.fitness_center_rounded,
                color: AppColors.primaryColor1),
          ],
        ),

        if (dashboard.trainees.any((t) => t.membershipExpiringSoon)) ...[
          const SizedBox(height: 24),
          Text(l10n.expiringMemberships,
              style: TextStyle(
                  color: colors.fg, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...dashboard.trainees
              .where((t) => t.membershipExpiringSoon)
              .map((t) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.card_membership_rounded,
                            color: Color(0xFFF59E0B), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(t.fullName,
                                style: TextStyle(
                                    color: colors.fg,
                                    fontWeight: FontWeight.w600))),
                        Text(l10n.expiringWarning,
                            style: const TextStyle(
                                color: Color(0xFFF59E0B), fontSize: 11)),
                      ],
                    ),
                  )),
        ],

      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                Text(label, style: TextStyle(color: color, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trainee dashboard content ─────────────────────────────────────────────────
class _TraineeDashboardContent extends StatelessWidget {
  final AppLocalizations l10n;
  final dynamic colors;
  const _TraineeDashboardContent({required this.l10n, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: AppColors.primaryG,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.keepItUp,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(l10n.keepItUpHint,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(l10n.quickActions,
            style: TextStyle(
                color: colors.fg, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            _QuickCard(
              icon: Icons.fitness_center_rounded,
              label: l10n.myWorkout,
              color: AppColors.primaryColor1,
              colors: colors,
              onTap: () => _openDetails(context, 3),
            ),
            const SizedBox(width: 12),
            _QuickCard(
              icon: Icons.restaurant_menu_rounded,
              label: l10n.myMeals,
              color: const Color(0xFF10B981),
              colors: colors,
              onTap: () => _openDetails(context, 4),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _QuickCard(
              icon: Icons.photo_library_rounded,
              label: l10n.progressBody,
              color: const Color(0xFF8B5CF6),
              colors: colors,
              onTap: () => _openDetails(context, 5),
            ),
            const SizedBox(width: 12),
            _QuickCard(
              icon: Icons.analytics_rounded,
              label: l10n.inBody,
              color: const Color(0xFFF59E0B),
              colors: colors,
              onTap: () => _openDetails(context, 2),
            ),
          ],
        ),
      ],
    );
  }

  /// Opens the trainee's "My Details" hub on a specific tab:
  /// 2 = InBody, 3 = Workout, 4 = Meals, 5 = Progress.
  void _openDetails(BuildContext context, int tab) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyDetailsScreen(initialTab: tab)),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final dynamic colors;
  final VoidCallback? onTap;
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.colors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: colors.fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}
