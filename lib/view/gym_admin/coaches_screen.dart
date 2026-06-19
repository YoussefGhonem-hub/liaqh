import 'dart:async';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';

import 'package:fitnessapp/data/models/gym_admin_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/gym_admin_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/gym_admin/add_coach_screen.dart';
import 'package:fitnessapp/view/gym_admin/coach_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Gym Admin: list all coaches in the gym.
class CoachesScreen extends StatefulWidget {
  static const routeName = '/CoachesScreen';
  const CoachesScreen({Key? key}) : super(key: key);

  @override
  State<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends State<CoachesScreen> {
  Timer? _debounce;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<GymAdminProvider>().loadCoaches());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      context.read<GymAdminProvider>().loadMoreCoaches();
    }
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context
          .read<GymAdminProvider>()
          .loadCoaches(search: v.trim().isEmpty ? null : v.trim());
    });
  }

  Future<void> _addCoach() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddCoachScreen()),
    );
    if (added == true && mounted) {
      context.read<GymAdminProvider>().loadCoaches();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<GymAdminProvider>();
    final coaches = provider.coaches;

    return Scaffold(
      backgroundColor: colors.bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCoach,
        backgroundColor: AppColors.primaryColor1,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(l10n.addCoach, style: const TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(l10n.dashCoaches,
                      style: TextStyle(
                          color: colors.fg,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('${provider.coaches.length}',
                      style: TextStyle(color: colors.subFg)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: _onSearch,
                style: TextStyle(color: colors.fg),
                decoration: InputDecoration(
                  hintText: l10n.searchCoaches,
                  hintStyle: TextStyle(color: colors.mutedFg),
                  prefixIcon: Icon(Icons.search, color: colors.mutedFg),
                  filled: true,
                  fillColor: colors.card,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: provider.coachesLoading && provider.coaches.isEmpty
                  ? const LiaqhPageLoader()
                  : coaches.isEmpty
                      ? Center(
                          child: Text(l10n.noCoachesYet,
                              style: TextStyle(color: colors.subFg)))
                      : RefreshIndicator(
                          onRefresh: () =>
                              context.read<GymAdminProvider>().loadCoaches(),
                          child: ListView.builder(
                            controller: _scrollCtrl,
                            padding:
                                const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: coaches.length +
                                (provider.coachesHasMore ? 1 : 0),
                            itemBuilder: (_, i) {
                              if (i >= coaches.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: LiaqhMarkLoader(size: 34),
                                );
                              }
                              return _CoachCard(
                                coach: coaches[i],
                                colors: colors,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CoachDetailScreen(coach: coaches[i]),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final GymCoach coach;
  final AppThemeColors colors;
  final VoidCallback onTap;
  const _CoachCard(
      {required this.coach, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          child: Text(
            coach.fullName.isNotEmpty ? coach.fullName[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Color(0xFF8B5CF6), fontWeight: FontWeight.w800),
          ),
        ),
        title: Text(coach.fullName,
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
        subtitle: Text(coach.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.subFg, fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
                coach.traineeLimit > 0
                    ? '${coach.traineeCount}/${coach.traineeLimit}'
                    : '${coach.traineeCount}',
                style: const TextStyle(
                    color: AppColors.primaryColor1,
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
            Text(AppLocalizations.of(context).traineesLower,
                style: TextStyle(color: colors.mutedFg, fontSize: 10)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
