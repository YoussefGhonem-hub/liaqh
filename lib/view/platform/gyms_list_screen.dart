import 'package:fitnessapp/data/models/platform_models.dart';
import 'package:fitnessapp/providers/platform_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'gym_detail_screen.dart';
import 'platform_widgets.dart';

class GymsListScreen extends StatefulWidget {
  static const routeName = '/GymsListScreen';
  const GymsListScreen({super.key});

  @override
  State<GymsListScreen> createState() => _GymsListScreenState();
}

class _GymsListScreenState extends State<GymsListScreen> {
  String _search = '';
  bool? _activeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context
        .read<PlatformProvider>()
        .loadGyms(search: _search, isActive: _activeFilter);
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
                title: 'Gyms',
                subtitle: 'Manage all registered gyms',
                icon: Icons.fitness_center_rounded,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    PlatformSearchField(
                      hint: 'Search gyms...',
                      onChanged: (v) {
                        _search = v;
                        _load();
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _filterChip('All', null),
                        const SizedBox(width: 8),
                        _filterChip('Active', true),
                        const SizedBox(width: 8),
                        _filterChip('Inactive', false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (p.gymsLoading && p.gyms.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (p.gymsError != null && p.gyms.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: PlatformErrorState(
                    message: p.gymsError!, onRetry: _load),
              )
            else if (p.gyms.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: PlatformEmptyState(
                  icon: Icons.fitness_center_rounded,
                  message: 'No gyms found',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _gymTile(p.gyms[i]),
                    ),
                    childCount: p.gyms.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool? value) {
    final selected = _activeFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _activeFilter = value);
        _load();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: AppColors.primaryG)
              : null,
          color: selected ? null : context.colors.chipUnselected,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : context.colors.subFg,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _gymTile(GymSummary g) {
    final colors = context.colors;
    return PlatformCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GymDetailScreen(gymId: g.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: colors.fg,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(g.ownerEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.subFg, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PlatformStatusChip(active: g.isActive),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniStat(Icons.sports_rounded, '${g.coachCount}', 'Coaches'),
              _miniStat(Icons.groups_rounded,
                  '${g.activeTraineeCount}/${g.traineeCount}', 'Trainees'),
              _miniStat(Icons.payments_rounded,
                  platformMoney(g.totalRevenue, g.currency), 'Revenue'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (g.isPersonal)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Personal',
                      style: TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              const Spacer(),
              Text(g.isActive ? 'Deactivate' : 'Activate',
                  style: TextStyle(
                      color: colors.subFg,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              Switch(
                value: g.isActive,
                onChanged: (v) => _toggle(g, v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(GymSummary g, bool v) async {
    try {
      await context.read<PlatformProvider>().setGymStatus(g.id, v);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  Widget _miniStat(IconData icon, String value, String label) {
    final colors = context.colors;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primaryColor1),
              const SizedBox(width: 4),
              Flexible(
                child: Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: colors.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: colors.mutedFg, fontSize: 10)),
        ],
      ),
    );
  }
}
