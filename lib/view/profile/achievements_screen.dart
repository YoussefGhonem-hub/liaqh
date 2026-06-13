import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  static const routeName = '/AchievementsScreen';
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.achievementsTitle,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Stats row
            Row(
              children: [
                _StatCard(
                  icon: Icons.stars_rounded,
                  label: l10n.totalPoints,
                  value: '0',
                  color: const Color(0xFFFFC107),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  label: l10n.currentStreak,
                  value: '0 ${l10n.days}',
                  color: Colors.deepOrange,
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Badges placeholder
            Text(l10n.badges,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.fg)),
            const SizedBox(height: 20),
            Icon(Icons.emoji_events_outlined,
                size: 72,
                color: AppColors.primaryColor1.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(l10n.noAchievementsYet,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.fg)),
            const SizedBox(height: 8),
            Text(l10n.noAchievementsHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.subFg)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color)),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11, color: context.colors.subFg)),
            ],
          ),
        ),
      );
}
