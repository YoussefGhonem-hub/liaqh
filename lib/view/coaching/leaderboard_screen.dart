import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/providers/coaching_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatefulWidget {
  static const routeName = '/LeaderboardScreen';
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _by = 'streak';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() => context.read<CoachingProvider>().loadLeaderboard(by: _by);

  Color _medal(int rank) {
    switch (rank) {
      case 0:
        return const Color(0xFFFFC107);
      case 1:
        return const Color(0xFFB0BEC5);
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final p = context.watch<CoachingProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        title: Text(l10n.leaderboard,
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _chip(l10n.byStreak, 'streak'),
                const SizedBox(width: 8),
                _chip(l10n.byMonth, 'month'),
              ],
            ),
          ),
          Expanded(
            child: p.leaderboardLoading
                ? const LiaqhPageLoader()
                : p.leaderboard.isEmpty
                    ? Center(
                        child: Text(l10n.noTraineesYet,
                            style: TextStyle(color: colors.subFg)))
                    : RefreshIndicator(
                        onRefresh: () async => _load(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: p.leaderboard.length,
                          itemBuilder: (_, i) {
                            final e = p.leaderboard[i];
                            final medal = _medal(i);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.card,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: medal == Colors.transparent
                                        ? colors.divider
                                        : medal.withValues(alpha: 0.6)),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 28,
                                    child: i < 3
                                        ? Icon(Icons.emoji_events,
                                            color: medal, size: 22)
                                        : Text('${i + 1}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: colors.subFg,
                                                fontWeight: FontWeight.w800)),
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.primaryColor1
                                        .withValues(alpha: 0.15),
                                    child: Text(
                                      e.name.isNotEmpty
                                          ? e.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          color: AppColors.primaryColor1,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(e.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: colors.fg,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  Text(
                                    _by == 'streak'
                                        ? '${e.value} 🔥'
                                        : '${e.value} 🏋️',
                                    style: const TextStyle(
                                        color: AppColors.primaryColor1,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = _by == value;
    return GestureDetector(
      onTap: () {
        setState(() => _by = value);
        _load();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient:
              selected ? LinearGradient(colors: AppColors.primaryG) : null,
          color: selected ? null : context.colors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : context.colors.subFg,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ),
    );
  }
}
