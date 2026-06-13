import 'package:fitnessapp/data/models/platform_models.dart';
import 'package:fitnessapp/providers/platform_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'platform_widgets.dart';

class PlatformCoachesScreen extends StatefulWidget {
  static const routeName = '/PlatformCoachesScreen';
  const PlatformCoachesScreen({super.key});

  @override
  State<PlatformCoachesScreen> createState() => _PlatformCoachesScreenState();
}

class _PlatformCoachesScreenState extends State<PlatformCoachesScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context.read<PlatformProvider>().loadCoaches(search: _search);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final p = context.watch<PlatformProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: PlatformGradientHeader(
                title: 'Coaches',
                subtitle: 'All coaches across gyms',
                icon: Icons.sports_rounded,
                showBack: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: PlatformSearchField(
                  hint: 'Search coaches...',
                  onChanged: (v) {
                    _search = v;
                    _load();
                  },
                ),
              ),
            ),
            if (p.coachesLoading && p.coaches.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (p.coachesError != null && p.coaches.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: PlatformErrorState(
                    message: p.coachesError!, onRetry: _load),
              )
            else if (p.coaches.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: PlatformEmptyState(
                    icon: Icons.sports_rounded, message: 'No coaches found'),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _coachTile(p.coaches[i]),
                    ),
                    childCount: p.coaches.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _coachTile(PlatformCoach c) {
    final colors = context.colors;
    final limitText =
        c.traineeLimit > 0 ? '${c.traineeCount}/${c.traineeLimit}' : '${c.traineeCount}';
    final atLimit = c.traineeLimit > 0 && c.traineeCount >= c.traineeLimit;
    return PlatformCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryColor1.withValues(alpha: 0.15),
            child: Text(
              c.fullName.isNotEmpty ? c.fullName[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: AppColors.primaryColor1, fontWeight: FontWeight.w700),
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
                const SizedBox(height: 2),
                Text(c.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.subFg, fontSize: 12)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.fitness_center_rounded,
                        size: 12, color: colors.mutedFg),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(c.gymName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: colors.mutedFg, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PlatformStatusChip(active: c.isActive),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_rounded,
                      size: 14,
                      color: atLimit
                          ? AppColors.errorColor
                          : AppColors.primaryColor1),
                  const SizedBox(width: 4),
                  Text(limitText,
                      style: TextStyle(
                          color: atLimit
                              ? AppColors.errorColor
                              : colors.fg,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
