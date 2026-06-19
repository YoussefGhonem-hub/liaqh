import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/providers/gym_admin_provider.dart';
import 'package:fitnessapp/view/gym_admin/unpaid_trainees_screen.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Gym Admin home — gym-wide statistics.
class GymAdminDashboardScreen extends StatefulWidget {
  const GymAdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<GymAdminDashboardScreen> createState() =>
      _GymAdminDashboardScreenState();
}

class _GymAdminDashboardScreenState extends State<GymAdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<GymAdminProvider>().loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<GymAdminProvider>();
    final d = provider.dashboard;
    final name = context.read<AuthProvider>().currentUser?.firstName ?? 'Admin';

    return Scaffold(
      backgroundColor: colors.bg,
      body: RefreshIndicator(
        onRefresh: () => context.read<GymAdminProvider>().loadDashboard(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            // Header
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
                  Text(l10n.dashGymDashboard,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(l10n.dashWelcomeUser(name),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (provider.dashboardLoading && d == null)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: const LiaqhPageLoader(),
              )
            else if (d != null) ...[
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _StatCard(
                      label: l10n.dashCoaches,
                      value: '${d.totalCoaches}',
                      icon: Icons.sports_rounded,
                      color: const Color(0xFF8B5CF6),
                      colors: colors),
                  _StatCard(
                      label: l10n.dashTrainees,
                      value: '${d.totalTrainees}',
                      icon: Icons.groups_rounded,
                      color: const Color(0xFF3B82F6),
                      colors: colors),
                  _StatCard(
                      label: l10n.dashActiveMembers,
                      value: '${d.activeMembers}',
                      icon: Icons.verified_user_rounded,
                      color: AppColors.successColor,
                      colors: colors),
                  _StatCard(
                      label: l10n.dashMonthlyRevenue,
                      value: 'EGP ${d.expectedMonthlyRevenue.toStringAsFixed(0)}',
                      icon: Icons.payments_rounded,
                      color: AppColors.primaryColor1,
                      colors: colors),
                  _StatCard(
                      label: l10n.dashExpiringThisWeek,
                      value: '${d.expiringThisWeek}',
                      icon: Icons.timer_outlined,
                      color: AppColors.warningColor,
                      colors: colors),
                  _StatCard(
                      label: l10n.dashNewThisMonth,
                      value: '+${d.newTraineesThisMonth}',
                      icon: Icons.person_add_rounded,
                      color: const Color(0xFF06B6D4),
                      colors: colors),
                ],
              ),
              const SizedBox(height: 12),
              // Unpaid trainees highlight — tap to see who.
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UnpaidTraineesScreen())),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.errorColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.report_gmailerrorred_rounded,
                          color: AppColors.errorColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.dashUnpaidTraineesAlert(d.unpaidTrainees),
                          style: TextStyle(
                              color: colors.fg,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.errorColor),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final AppThemeColors colors;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(
                    color: colors.fg,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: colors.subFg,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
