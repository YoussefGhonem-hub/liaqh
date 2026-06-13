import 'dart:async';
import 'package:fitnessapp/data/models/workout_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/workout_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/utils/muscle_group_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Trainee-facing (or coach-supervised) screen: logs sets for a WorkoutDay.
/// traineeId — the Trainee profile ID (not User.Id)
class WorkoutDaySessionScreen extends StatefulWidget {
  final WorkoutDay day;
  final String traineeId;

  const WorkoutDaySessionScreen({
    Key? key,
    required this.day,
    required this.traineeId,
  }) : super(key: key);

  @override
  State<WorkoutDaySessionScreen> createState() => _WorkoutDaySessionScreenState();
}

class _WorkoutDaySessionScreenState extends State<WorkoutDaySessionScreen> {
  // For each exercise, one SetLogDraft per prescribed set
  late List<List<SetLogDraft>> _setDrafts;

  // Rest timer
  Timer? _restTimer;
  int _restSeconds = 0;
  bool _timerRunning = false;

  bool _allWeightsPrescribed = true;
  final _notesCtrl = TextEditingController();
  int _effort = 7;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setDrafts = widget.day.exercises.map((ex) {
      return List.generate(
        ex.sets,
        (i) => SetLogDraft(
          reps: int.tryParse(ex.repsTarget.replaceAll(RegExp(r'[^0-9]'), '').substring(0, 1)) ?? 8,
          weightKg: ex.startingWeightKg ?? 0,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _restTimer?.cancel();
    setState(() { _restSeconds = seconds; _timerRunning = true; });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restSeconds <= 0) {
        t.cancel();
        setState(() => _timerRunning = false);
      } else {
        setState(() => _restSeconds--);
      }
    });
  }

  void _stopTimer() {
    _restTimer?.cancel();
    setState(() { _restSeconds = 0; _timerRunning = false; });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    // Build sets payload
    final allSets = <Map<String, dynamic>>[];
    for (int i = 0; i < widget.day.exercises.length; i++) {
      final ex = widget.day.exercises[i];
      for (int s = 0; s < _setDrafts[i].length; s++) {
        if (_setDrafts[i][s].done) {
          allSets.add(_setDrafts[i][s].toJson(ex.id, s + 1));
        }
      }
    }
    if (allSets.isEmpty) {
      setState(() => _error = l10n.logAtLeastOneSet);
      return;
    }

    final provider = context.read<WorkoutProvider>();
    final ok = await provider.logWorkoutDay(
      traineeId: widget.traineeId,
      workoutDayId: widget.day.id,
      trainedOn: DateTime.now(),
      allWeightsPrescribed: _allWeightsPrescribed,
      traineeNotes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      overallEffort: _effort,
      sets: allSets,
    );
    if (ok && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<WorkoutProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(widget.day.dayName,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.fg,
                fontSize: 17)),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
      ),
      body: Column(
        children: [
          // Rest timer bar
          if (_timerRunning)
            Container(
              color: AppColors.primaryColor1,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.rest(_restSeconds),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _stopTimer,
                    child: Text(l10n.skip,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.day.exercises.length + 1, // +1 for footer
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) {
                if (i == widget.day.exercises.length) {
                  // Footer — effort, notes, submit
                  return _buildFooter(provider, l10n, colors);
                }
                final ex = widget.day.exercises[i];
                return _ExerciseLogCard(
                  exercise: ex,
                  drafts: _setDrafts[i],
                  onSetDone: (setIdx) {
                    setState(() => _setDrafts[i][setIdx].done = true);
                    _startTimer(ex.restSeconds);
                  },
                  onChanged: () => setState(() {}),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(WorkoutProvider provider, AppLocalizations l10n, AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Used prescribed weights?
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.listTile,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.usedPrescribedWeights,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: colors.fg),
                ),
              ),
              Switch(
                value: _allWeightsPrescribed,
                activeThumbColor: AppColors.primaryColor1,
                onChanged: (v) => setState(() => _allWeightsPrescribed = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Overall effort 1-10
        Text(l10n.overallEffort,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: colors.fg)),
        const SizedBox(height: 6),
        Row(
          children: List.generate(10, (i) {
            final v = i + 1;
            final sel = _effort == v;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _effort = v),
                child: Container(
                  margin: EdgeInsets.only(right: i < 9 ? 4 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primaryColor1
                        : colors.listTile,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('$v',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: sel
                                ? Colors.white
                                : colors.subFg)),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesCtrl,
          keyboardType: TextInputType.multiline,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: l10n.sessionNotes,
            filled: true,
            fillColor: colors.listTile,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!,
              style: const TextStyle(
                  color: AppColors.errorColor, fontSize: 13)),
        ],
        const SizedBox(height: 20),
        provider.loading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(l10n.confirmWorkoutCompleted,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor1,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Exercise log card ─────────────────────────────────────────────────────────
class _ExerciseLogCard extends StatelessWidget {
  final WorkoutExerciseItem exercise;
  final List<SetLogDraft> drafts;
  final void Function(int setIdx) onSetDone;
  final VoidCallback onChanged;

  const _ExerciseLogCard({
    required this.exercise,
    required this.drafts,
    required this.onSetDone,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Muscle-group animated banner
          MuscleGroupBanner(
            muscleGroup: exercise.muscleGroup,
            exerciseName: exercise.exerciseNameEn,
            height: 90,
          ),
          Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Meta row: sets × reps · rest · weight
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  children: [
                    _metaChip('${exercise.sets} ${l10n.sets} × ${exercise.repsTarget}',
                        Icons.repeat, colors),
                    _metaChip(l10n.rest(exercise.restSeconds),
                        Icons.timer_outlined, colors),
                  ],
                ),
              ),
              if (exercise.startingWeightKg != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor1.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${exercise.startingWeightKg!.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                        color: AppColors.primaryColor1,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Set rows
          ...List.generate(drafts.length, (i) => _SetRow(
                setNumber: i + 1,
                draft: drafts[i],
                prescribed: exercise.startingWeightKg,
                onDone: () => onSetDone(i),
                onChanged: onChanged,
              )),
        ],
          ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(String label, IconData icon, AppThemeColors colors) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: colors.subFg),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: colors.subFg,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _SetRow extends StatelessWidget {
  final int setNumber;
  final SetLogDraft draft;
  final double? prescribed;
  final VoidCallback onDone;
  final VoidCallback onChanged;

  const _SetRow({
    required this.setNumber,
    required this.draft,
    this.prescribed,
    required this.onDone,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: draft.done
            ? AppColors.successColor.withValues(alpha: 0.08)
            : colors.card,
        borderRadius: BorderRadius.circular(10),
        border: draft.done
            ? Border.all(color: AppColors.successColor.withValues(alpha: 0.4))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('S$setNumber',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: colors.subFg)),
          ),
          // Reps
          Expanded(
            child: _CompactInput(
              label: l10n.reps,
              value: draft.reps.toString(),
              onChanged: (v) {
                draft.reps = int.tryParse(v) ?? draft.reps;
                onChanged();
              },
            ),
          ),
          const SizedBox(width: 8),
          // Weight
          Expanded(
            child: _CompactInput(
              label: 'kg',
              value: draft.weightKg.toStringAsFixed(1),
              isDecimal: true,
              onChanged: (v) {
                draft.weightKg = double.tryParse(v) ?? draft.weightKg;
                onChanged();
              },
            ),
          ),
          const SizedBox(width: 8),
          // Done button
          GestureDetector(
            onTap: draft.done ? null : onDone,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: draft.done
                    ? AppColors.successColor
                    : AppColors.primaryColor1,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                draft.done ? Icons.check : Icons.done,
                color: Colors.white, size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactInput extends StatelessWidget {
  final String label;
  final String value;
  final bool isDecimal;
  final ValueChanged<String> onChanged;

  const _CompactInput({
    required this.label,
    required this.value,
    this.isDecimal = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: colors.subFg,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          TextFormField(
            initialValue: value,
            onChanged: onChanged,
            keyboardType: isDecimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              filled: true,
              fillColor: colors.listTile,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      );
  }
}
