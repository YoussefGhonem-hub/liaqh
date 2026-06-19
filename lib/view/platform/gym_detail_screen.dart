import 'package:fitnessapp/data/models/platform_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/providers/platform_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'platform_widgets.dart';
import 'plans_management_screen.dart';

class GymDetailScreen extends StatefulWidget {
  static const routeName = '/GymDetailScreen';
  final String gymId;
  const GymDetailScreen({super.key, required this.gymId});

  @override
  State<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends State<GymDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlatformProvider>().loadGymDetail(widget.gymId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final p = context.watch<PlatformProvider>();
    final g = p.gymDetail;

    return Scaffold(
      backgroundColor: colors.bg,
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<PlatformProvider>().loadGymDetail(widget.gymId),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PlatformGradientHeader(
                title: g?.name ?? 'Gym',
                subtitle: g?.ownerEmail ?? 'Loading...',
                icon: Icons.fitness_center_rounded,
                showBack: true,
              ),
            ),
            if (p.gymDetailLoading && g == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: const LiaqhPageLoader(),
              )
            else if (p.gymDetailError != null && g == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: PlatformErrorState(
                  message: p.gymDetailError!,
                  onRetry: () => context
                      .read<PlatformProvider>()
                      .loadGymDetail(widget.gymId),
                ),
              )
            else if (g != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _statusBar(g),
                    const SizedBox(height: 16),
                    _kpiRow(g),
                    const SizedBox(height: 16),
                    _infoCard(g),
                    const SizedBox(height: 20),
                    PlatformSectionTitle('Coaches (${g.coaches.length})'),
                    const SizedBox(height: 10),
                    if (g.coaches.isEmpty)
                      const PlatformEmptyState(
                          icon: Icons.sports_rounded,
                          message: 'No coaches')
                    else
                      ...g.coaches.map(_coachTile),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: PlatformSectionTitle(
                              'Plans (${g.plans.length})'),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlansManagementScreen(
                                  gymId: g.id, gymName: g.name),
                            ),
                          ),
                          icon: const Icon(Icons.settings_rounded, size: 18),
                          label: const Text('Manage Plans'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (g.plans.isEmpty)
                      const PlatformEmptyState(
                          icon: Icons.card_membership_rounded,
                          message: 'No plans')
                    else
                      ...g.plans.map((pl) => _planTile(pl, g.currency)),
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

  Widget _statusBar(GymDetail g) {
    return PlatformCard(
      child: Row(
        children: [
          PlatformStatusChip(active: g.isActive),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _toggle(g),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  g.isActive ? AppColors.errorColor : AppColors.successColor,
              minimumSize: const Size(0, 42),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            icon: Icon(
                g.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                size: 18),
            label: Text(g.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(GymDetail g) async {
    try {
      await context.read<PlatformProvider>().setGymStatus(g.id, !g.isActive);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  Widget _kpiRow(GymDetail g) {
    return Row(
      children: [
        Expanded(
          child: PlatformKpiCard(
            label: 'Coaches',
            value: '${g.coachCount}',
            icon: Icons.sports_rounded,
            color: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PlatformKpiCard(
            label: 'Trainees',
            value: '${g.traineeCount}',
            icon: Icons.groups_rounded,
            color: const Color(0xFF3B82F6),
            footer: '${g.activeMembershipCount} active',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PlatformKpiCard(
            label: 'Revenue',
            value: platformMoney(g.totalRevenue, g.currency),
            icon: Icons.payments_rounded,
            color: AppColors.successColor,
            footer: platformMoney(g.revenueThisMonth, g.currency),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(GymDetail g) {
    return PlatformCard(
      child: Column(
        children: [
          _infoRow('Owner', g.ownerEmail),
          _infoRow('Currency', g.currency),
          _infoRow('Time zone', g.timeZone),
          _infoRow('Language', g.defaultLanguage),
          _infoRow('Type', g.isPersonal ? 'Personal' : 'Gym'),
          if (g.createdAt != null)
            _infoRow('Created',
                '${g.createdAt!.year}-${g.createdAt!.month.toString().padLeft(2, '0')}-${g.createdAt!.day.toString().padLeft(2, '0')}'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(color: colors.subFg, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: colors.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _coachTile(GymCoach c) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PlatformCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryColor1.withValues(alpha: 0.15),
              child: Text(
                c.fullName.isNotEmpty ? c.fullName[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: AppColors.primaryColor1,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: colors.fg, fontWeight: FontWeight.w700)),
                  Text(c.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.subFg, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PlatformStatusChip(active: c.isActive),
                const SizedBox(height: 4),
                Text('${c.traineeCount} trainees',
                    style: TextStyle(color: colors.mutedFg, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _planTile(GymPlan pl, String currency) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PlatformCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryColor1.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.card_membership_rounded,
                  color: AppColors.primaryColor1, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pl.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: colors.fg, fontWeight: FontWeight.w700)),
                  Text('${pl.durationDays} days',
                      style: TextStyle(color: colors.subFg, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(platformMoney(pl.price, currency),
                    style: TextStyle(
                        color: colors.fg, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                PlatformStatusChip(active: pl.isActive),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
