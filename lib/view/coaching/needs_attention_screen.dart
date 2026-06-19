import 'package:fitnessapp/data/models/coaching_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/coaching_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NeedsAttentionScreen extends StatefulWidget {
  static const routeName = '/NeedsAttentionScreen';
  const NeedsAttentionScreen({super.key});

  @override
  State<NeedsAttentionScreen> createState() => _NeedsAttentionScreenState();
}

class _NeedsAttentionScreenState extends State<NeedsAttentionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<CoachingProvider>().loadNeedsAttention());
  }

  ({Color color, IconData icon, String label}) _flag(
      AppLocalizations l10n, String f) {
    if (f.startsWith('inactive:')) {
      final days = int.tryParse(f.split(':').last) ?? 0;
      return (
        color: Colors.orange,
        icon: Icons.bedtime_outlined,
        label: l10n.flagInactiveDays(days)
      );
    }
    switch (f) {
      case 'no_plan':
        return (
          color: const Color(0xFF6C63FF),
          icon: Icons.assignment_late_outlined,
          label: l10n.flagNoPlan
        );
      case 'inactive':
        return (
          color: Colors.orange,
          icon: Icons.bedtime_outlined,
          label: l10n.flagInactive
        );
      case 'rejected_meal':
        return (
          color: AppColors.errorColor,
          icon: Icons.restaurant_outlined,
          label: l10n.flagRejectedMeal
        );
      case 'expiring':
        return (
          color: const Color(0xFFF59E0B),
          icon: Icons.workspace_premium_outlined,
          label: l10n.flagExpiring
        );
      default:
        return (color: Colors.grey, icon: Icons.flag_outlined, label: f);
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
        title: Text(l10n.needsAttention,
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      body: p.needsLoading
          ? const LiaqhPageLoader()
          : p.needsAttention.isEmpty
              ? Center(
                  child: Text(l10n.everyoneOnTrack,
                      style: TextStyle(color: colors.subFg, fontSize: 15)))
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<CoachingProvider>().loadNeedsAttention(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: p.needsAttention.length,
                    itemBuilder: (_, i) {
                      final NeedsAttentionItem t = p.needsAttention[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primaryColor1
                                      .withValues(alpha: 0.15),
                                  child: Text(
                                    t.name.isNotEmpty
                                        ? t.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        color: AppColors.primaryColor1,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(t.name,
                                      style: TextStyle(
                                          color: colors.fg,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: t.flags.map((f) {
                                final s = _flag(l10n, f);
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: s.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(s.icon, size: 13, color: s.color),
                                      const SizedBox(width: 5),
                                      Text(s.label,
                                          style: TextStyle(
                                              color: s.color,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
