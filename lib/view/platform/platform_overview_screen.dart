import 'package:fitnessapp/data/models/platform_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/platform_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'payment_methods_management_screen.dart';
import 'payment_requests_screen.dart';
import 'platform_widgets.dart';

class PlatformOverviewScreen extends StatefulWidget {
  static const routeName = '/PlatformOverviewScreen';
  const PlatformOverviewScreen({super.key});

  @override
  State<PlatformOverviewScreen> createState() => _PlatformOverviewScreenState();
}

class _PlatformOverviewScreenState extends State<PlatformOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlatformProvider>().loadOverview();
    });
  }

  String _money(double v, String currency) =>
      '${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)} $currency';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final p = context.watch<PlatformProvider>();
    final o = p.overview;

    return Scaffold(
      backgroundColor: colors.bg,
      body: RefreshIndicator(
        onRefresh: () => context.read<PlatformProvider>().loadOverview(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PlatformGradientHeader(
                title: l10n.dashPlatform,
                subtitle: l10n.dashPlatformSubtitle,
                icon: Icons.dashboard_rounded,
              ),
            ),
            if (p.overviewLoading && o == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: const LiaqhPageLoader(),
              )
            else if (p.overviewError != null && o == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: PlatformErrorState(
                  message: p.overviewError!,
                  onRetry: () =>
                      context.read<PlatformProvider>().loadOverview(),
                ),
              )
            else if (o != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _kpiGrid(o),
                    const SizedBox(height: 24),
                    PlatformSectionTitle(l10n.dashPayments),
                    const SizedBox(height: 12),
                    _ManageTile(
                      icon: Icons.fact_check_rounded,
                      title: l10n.dashPaymentRequests,
                      subtitle: l10n.dashPaymentRequestsSubtitle,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PaymentRequestsScreen())),
                    ),
                    const SizedBox(height: 10),
                    _ManageTile(
                      icon: Icons.tune_rounded,
                      title: l10n.dashPaymentMethods,
                      subtitle: l10n.dashPaymentMethodsSubtitle,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const PaymentMethodsManagementScreen())),
                    ),
                    const SizedBox(height: 24),
                    PlatformSectionTitle(l10n.dashRevenueLastMonths),
                    const SizedBox(height: 12),
                    _revenueBars(o),
                    const SizedBox(height: 24),
                    PlatformSectionTitle(l10n.dashGrowth),
                    const SizedBox(height: 12),
                    _growthCard(o),
                  ]),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _kpiGrid(PlatformOverview o) {
    final l10n = AppLocalizations.of(context);
    final items = <Widget>[
      PlatformKpiCard(
        label: l10n.dashTotalGyms,
        value: '${o.totalGyms}',
        icon: Icons.fitness_center_rounded,
        color: AppColors.primaryColor1,
        footer: l10n.dashGymsActiveInactive(o.activeGyms, o.inactiveGyms),
      ),
      PlatformKpiCard(
        label: l10n.dashTotalRevenue,
        value: _money(o.totalRevenue, o.currency),
        icon: Icons.payments_rounded,
        color: AppColors.successColor,
        footer: l10n.dashThisMonthAmount(_money(o.revenueThisMonth, o.currency)),
      ),
      PlatformKpiCard(
        label: l10n.dashTrainees,
        value: '${o.totalTrainees}',
        icon: Icons.groups_rounded,
        color: const Color(0xFF3B82F6),
        footer: l10n.dashPlusThisMonth(o.newTraineesThisMonth),
      ),
      PlatformKpiCard(
        label: l10n.dashCoaches,
        value: '${o.totalCoaches}',
        icon: Icons.sports_rounded,
        color: const Color(0xFF8B5CF6),
        footer: l10n.dashAdminsCount(o.totalAdmins),
      ),
      PlatformKpiCard(
        label: l10n.dashInBodyRecords,
        value: '${o.totalInBodyMeasurements}',
        icon: Icons.monitor_weight_rounded,
        color: const Color(0xFF06B6D4),
      ),
      PlatformKpiCard(
        label: l10n.dashWorkoutSessions,
        value: '${o.totalWorkoutSessions}',
        icon: Icons.directions_run_rounded,
        color: AppColors.warningColor,
      ),
      PlatformKpiCard(
        label: l10n.dashMealPlans,
        value: '${o.totalMealPlans}',
        icon: Icons.restaurant_rounded,
        color: const Color(0xFF10B981),
      ),
      PlatformKpiCard(
        label: l10n.dashNewGyms,
        value: '+${o.newGymsThisMonth}',
        icon: Icons.add_business_rounded,
        color: AppColors.primaryColor2,
        footer: l10n.dashThisMonth,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.28,
      children: items,
    );
  }

  Widget _revenueBars(PlatformOverview o) {
    if (o.monthlyRevenue.isEmpty) {
      return PlatformEmptyState(
        icon: Icons.bar_chart_rounded,
        message: AppLocalizations.of(context).dashNoRevenueData,
      );
    }
    final maxAmount = o.monthlyRevenue
        .map((e) => e.amount)
        .fold<double>(0, (a, b) => b > a ? b : a);
    return PlatformCard(
      child: Column(
        children: [
          for (final m in o.monthlyRevenue)
            _MiniBar(
              label: m.month,
              value: m.amount,
              max: maxAmount,
              currency: o.currency,
            ),
        ],
      ),
    );
  }

  Widget _growthCard(PlatformOverview o) {
    if (o.monthlyGrowth.isEmpty) {
      return PlatformEmptyState(
        icon: Icons.trending_up_rounded,
        message: AppLocalizations.of(context).dashNoGrowthData,
      );
    }
    final colors = context.colors;
    return PlatformCard(
      child: Column(
        children: [
          for (final g in o.monthlyGrowth)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(g.month,
                        style: TextStyle(
                            color: colors.fg, fontWeight: FontWeight.w600)),
                  ),
                  _growthChip(Icons.add_business_rounded, g.newGyms,
                      AppColors.primaryColor1),
                  const SizedBox(width: 8),
                  _growthChip(Icons.person_add_rounded, g.newTrainees,
                      const Color(0xFF3B82F6)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _growthChip(IconData icon, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text('+$value',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final String currency;
  const _MiniBar({
    required this.label,
    required this.value,
    required this.max,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final frac = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(label,
                style: TextStyle(color: colors.subFg, fontSize: 12)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: frac,
                minHeight: 10,
                backgroundColor: colors.listTile,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primaryColor1),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 76,
            child: Text(
              '${value.toStringAsFixed(0)} $currency',
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: colors.fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ManageTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryColor1.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryColor1),
        ),
        title: Text(title,
            style: TextStyle(
                color: colors.fg, fontWeight: FontWeight.w700, fontSize: 14.5)),
        subtitle: Text(subtitle,
            style: TextStyle(color: colors.subFg, fontSize: 12)),
        trailing: Icon(Icons.chevron_right_rounded, color: colors.mutedFg),
        onTap: onTap,
      ),
    );
  }
}
