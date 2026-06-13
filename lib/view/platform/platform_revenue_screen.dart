import 'package:fitnessapp/data/models/platform_models.dart';
import 'package:fitnessapp/providers/platform_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'platform_widgets.dart';

class PlatformRevenueScreen extends StatefulWidget {
  static const routeName = '/PlatformRevenueScreen';
  const PlatformRevenueScreen({super.key});

  @override
  State<PlatformRevenueScreen> createState() => _PlatformRevenueScreenState();
}

class _PlatformRevenueScreenState extends State<PlatformRevenueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlatformProvider>().loadRevenue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final p = context.watch<PlatformProvider>();
    final r = p.revenue;

    return Scaffold(
      backgroundColor: colors.bg,
      body: RefreshIndicator(
        onRefresh: () => context.read<PlatformProvider>().loadRevenue(),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: PlatformGradientHeader(
                title: 'Revenue',
                subtitle: 'Earnings across all gyms',
                icon: Icons.payments_rounded,
              ),
            ),
            if (p.revenueLoading && r == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (p.revenueError != null && r == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: PlatformErrorState(
                  message: p.revenueError!,
                  onRetry: () =>
                      context.read<PlatformProvider>().loadRevenue(),
                ),
              )
            else if (r != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _totals(r),
                    const SizedBox(height: 24),
                    const PlatformSectionTitle('Revenue by Gym'),
                    const SizedBox(height: 12),
                    _byGym(r),
                    const SizedBox(height: 24),
                    const PlatformSectionTitle('Monthly'),
                    const SizedBox(height: 12),
                    _monthly(r),
                    const SizedBox(height: 24),
                    const PlatformSectionTitle('Recent Transactions'),
                    const SizedBox(height: 12),
                    _transactions(r),
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

  Widget _totals(PlatformRevenue r) {
    return Row(
      children: [
        Expanded(
          child: PlatformKpiCard(
            label: 'Total Revenue',
            value: platformMoney(r.totalRevenue, r.currency),
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.successColor,
            footer: '${r.totalTransactions} transactions',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PlatformKpiCard(
            label: 'This Month',
            value: platformMoney(r.revenueThisMonth, r.currency),
            icon: Icons.calendar_month_rounded,
            color: AppColors.primaryColor1,
          ),
        ),
      ],
    );
  }

  Widget _byGym(PlatformRevenue r) {
    if (r.byGym.isEmpty) {
      return const PlatformEmptyState(
          icon: Icons.fitness_center_rounded, message: 'No revenue by gym');
    }
    final sorted = [...r.byGym]..sort((a, b) => b.revenue.compareTo(a.revenue));
    final maxRev =
        sorted.map((e) => e.revenue).fold<double>(0, (a, b) => b > a ? b : a);
    final colors = context.colors;
    return PlatformCard(
      child: Column(
        children: [
          for (final g in sorted)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(g.gymName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: colors.fg,
                                fontWeight: FontWeight.w600)),
                      ),
                      Text(platformMoney(g.revenue, r.currency),
                          style: TextStyle(
                              color: colors.fg,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: maxRev <= 0
                          ? 0
                          : (g.revenue / maxRev).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: colors.listTile,
                      valueColor: const AlwaysStoppedAnimation(
                          AppColors.primaryColor1),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('${g.transactionCount} transactions',
                      style: TextStyle(color: colors.mutedFg, fontSize: 11)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _monthly(PlatformRevenue r) {
    if (r.monthly.isEmpty) {
      return const PlatformEmptyState(
          icon: Icons.bar_chart_rounded, message: 'No monthly data');
    }
    final maxAmount =
        r.monthly.map((e) => e.amount).fold<double>(0, (a, b) => b > a ? b : a);
    final colors = context.colors;
    return PlatformCard(
      child: Column(
        children: [
          for (final m in r.monthly)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 58,
                    child: Text(m.month,
                        style:
                            TextStyle(color: colors.subFg, fontSize: 12)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: maxAmount <= 0
                            ? 0
                            : (m.amount / maxAmount).clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: colors.listTile,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.primaryColor1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 76,
                    child: Text(platformMoney(m.amount, r.currency),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: colors.fg,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _transactions(PlatformRevenue r) {
    if (r.recentTransactions.isEmpty) {
      return const PlatformEmptyState(
          icon: Icons.receipt_long_rounded,
          message: 'No recent transactions');
    }
    final colors = context.colors;
    return Column(
      children: [
        for (final t in r.recentTransactions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PlatformCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          AppColors.successColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.receipt_long_rounded,
                        color: AppColors.successColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.traineeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: colors.fg,
                                fontWeight: FontWeight.w700)),
                        Text(t.gymName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: colors.subFg, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(platformMoney(t.amount, t.currency),
                          style: TextStyle(
                              color: colors.fg,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(t.status,
                          style: TextStyle(
                              color: colors.mutedFg, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
