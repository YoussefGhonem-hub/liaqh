import 'package:fitnessapp/data/models/workout_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/workout_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  final String traineeId;
  final String traineeName;

  const WorkoutHistoryScreen({
    Key? key,
    required this.traineeId,
    required this.traineeName,
  }) : super(key: key);

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<WorkoutProvider>().loadHistory(widget.traineeId));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<WorkoutProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text('${widget.traineeName} — ${l10n.workoutHistory}',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.fg,
                fontSize: 16)),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
      ),
      body: provider.loading
          ? const LiaqhPageLoader()
          : provider.history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_outlined,
                          size: 64,
                          color: AppColors.primaryColor1),
                      const SizedBox(height: 16),
                      Text(l10n.noWorkoutsLogged,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.fg)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<WorkoutProvider>().loadHistory(widget.traineeId),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _WorkoutLogCard(log: provider.history[i]),
                  ),
                ),
    );
  }
}

class _WorkoutLogCard extends StatelessWidget {
  final WorkoutHistoryLog log;
  const _WorkoutLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.listTile,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(_fmtDate(log.trainedOn),
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: colors.fg)),
                  ),
                  if (log.overallEffort != null)
                    _badge(l10n.effort(log.overallEffort!),
                        AppColors.primaryColor1),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _badge(log.dayName, AppColors.grayColor),
                  const SizedBox(width: 6),
                  _badge(log.muscleGroupFocus, AppColors.grayColor),
                  const Spacer(),
                  Icon(
                    log.allWeightsPrescribed
                        ? Icons.check_circle
                        : Icons.warning_amber_rounded,
                    size: 16,
                    color: log.allWeightsPrescribed
                        ? AppColors.successColor
                        : AppColors.warningColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    log.allWeightsPrescribed
                        ? l10n.prescribedWeights
                        : l10n.modifiedWeights,
                    style: TextStyle(
                        fontSize: 11,
                        color: log.allWeightsPrescribed
                            ? AppColors.successColor
                            : AppColors.warningColor,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
        children: [
          if (log.exercises.isNotEmpty)
            ...log.exercises.map((ex) => _ExerciseSummaryRow(ex: ex)).toList()
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(l10n.noSetDetails,
                  style: TextStyle(color: colors.subFg, fontSize: 13)),
            ),
          if (log.traineeNotes != null && log.traineeNotes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_outlined,
                      size: 14, color: colors.subFg),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(log.traineeNotes!,
                        style: TextStyle(
                            color: colors.subFg, fontSize: 12)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600)),
      );
}

class _ExerciseSummaryRow extends StatelessWidget {
  final ExerciseSetSummary ex;
  const _ExerciseSummaryRow({required this.ex});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(ex.exerciseNameEn,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: colors.fg)),
              ),
              if (ex.prescribedWeightKg != null)
                Text('Rx: ${ex.prescribedWeightKg!.toStringAsFixed(1)} kg',
                    style: TextStyle(
                        fontSize: 11,
                        color: colors.subFg)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: ex.sets.map((s) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.listTile,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'S${s.setNo}: ${s.reps}r × ${s.weightKg.toStringAsFixed(1)}kg'
                    '${s.effort != null ? " (RPE ${s.effort})" : ""}',
                    style: TextStyle(
                        fontSize: 11,
                        color: colors.fg,
                        fontWeight: FontWeight.w500),
                  ),
                )).toList(),
          ),
        ],
      ),
    );
  }
}

String _fmtDate(String iso) {
  try {
    final d = DateTime.parse(iso);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  } catch (_) {
    return iso.length > 10 ? iso.substring(0, 10) : iso;
  }
}
