import 'package:fitnessapp/data/models/gym_admin_models.dart';
import 'package:fitnessapp/data/models/trainee_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/gym_admin_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/gym_admin/add_trainee_admin_screen.dart';
import 'package:fitnessapp/view/trainees/trainee_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Gym Admin: a coach's profile + the trainees under them.
class CoachDetailScreen extends StatefulWidget {
  final GymCoach coach;
  const CoachDetailScreen({Key? key, required this.coach}) : super(key: key);

  @override
  State<CoachDetailScreen> createState() => _CoachDetailScreenState();
}

class _CoachDetailScreenState extends State<CoachDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<GymAdminProvider>();
      p.loadCoachTrainees(widget.coach.userId);
      p.loadCoaches(); // for the reassign picker
    });
  }

  Future<void> _reassign(TraineeSummary t) async {
    final provider = context.read<GymAdminProvider>();
    final l10n = AppLocalizations.of(context);
    final others =
        provider.coaches.where((c) => c.userId != widget.coach.userId).toList();
    if (others.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noOtherCoachToReassign)));
      return;
    }
    final picked = await showDialog<GymCoach>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.reassignTraineeTo(t.fullName)),
        children: [
          for (final c in others)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, c),
              child: Text('${c.fullName}  (${c.traineeCount}/${c.traineeLimit})'),
            ),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    final ok = await provider.reassign(t.id, picked.userId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok
              ? l10n.reassignedToName(picked.fullName)
              : (provider.error ?? l10n.failedGeneric)),
          backgroundColor: ok ? AppColors.successColor : AppColors.errorColor));
      if (ok) provider.loadCoachTrainees(widget.coach.userId);
    }
  }

  Future<void> _addTrainee() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTraineeAdminScreen(
            coachUserId: widget.coach.userId, coachName: widget.coach.fullName),
      ),
    );
    if (added == true && mounted) {
      context.read<GymAdminProvider>().loadCoachTrainees(widget.coach.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final c = widget.coach;
    final provider = context.watch<GymAdminProvider>();
    final trainees = provider.traineesOf(c.userId);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        title: Text(c.fullName,
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTrainee,
        backgroundColor: AppColors.primaryColor1,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: Text(l10n.addTrainee, style: const TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<GymAdminProvider>().loadCoachTrainees(c.userId),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // Coach header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.divider),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    child: Text(
                        c.fullName.isNotEmpty
                            ? c.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w800,
                            fontSize: 20)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.email,
                            style:
                                TextStyle(color: colors.subFg, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                            c.traineeLimit > 0
                                ? '${c.traineeCount} / ${c.traineeLimit} ${l10n.traineesLower}'
                                : '${c.traineeCount} ${l10n.traineesLower}',
                            style: const TextStyle(
                                color: AppColors.primaryColor1,
                                fontWeight: FontWeight.w700)),
                        if (c.bio != null && c.bio!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(c.bio!,
                              style: TextStyle(
                                  color: colors.mutedFg, fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(l10n.dashTrainees,
                style: TextStyle(
                    color: colors.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (trainees.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                    child: Text(l10n.noTraineesUnderCoach,
                        style: TextStyle(color: colors.subFg))),
              )
            else
              ...trainees.map((t) => _TraineeCard(
                    t: t,
                    colors: colors,
                    onReassign: () => _reassign(t),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TraineeDetailScreen(
                          traineeId: t.id,
                          traineeName: t.fullName,
                          goal: t.goal,
                          heightCm: t.heightCm,
                          currentWeightKg: t.currentWeightKg,
                          latestBodyScore: t.latestBodyScore,
                          traineeUserId: t.userId,
                          profileImageUrl: t.profileImageUrl,
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _TraineeCard extends StatelessWidget {
  final TraineeSummary t;
  final AppThemeColors colors;
  final VoidCallback onTap;
  final VoidCallback onReassign;
  const _TraineeCard(
      {required this.t,
      required this.colors,
      required this.onTap,
      required this.onReassign});

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
          child: Text(
              t.fullName.isNotEmpty ? t.fullName[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Color(0xFF3B82F6), fontWeight: FontWeight.w700)),
        ),
        title: Text(t.fullName,
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
        subtitle: Text('${t.goal} · ${t.currentWeightKg.toStringAsFixed(0)} kg',
            style: TextStyle(color: colors.subFg, fontSize: 12)),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: colors.mutedFg),
          onSelected: (v) {
            if (v == 'open') onTap();
            if (v == 'reassign') onReassign();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
                value: 'open',
                child: Text(AppLocalizations.of(context).openDetails)),
            PopupMenuItem(
                value: 'reassign',
                child: Text(AppLocalizations.of(context).reassignCoach)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
