import 'dart:math';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';

import 'package:fitnessapp/data/models/workout_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/workout_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import 'exercise_library_screen.dart';

class BuildWorkoutDayScreen extends StatefulWidget {
  final String programId;
  final String programName;
  final String traineeId;
  final String traineeName;

  const BuildWorkoutDayScreen({
    Key? key,
    required this.programId,
    required this.programName,
    required this.traineeId,
    required this.traineeName,
  }) : super(key: key);

  @override
  State<BuildWorkoutDayScreen> createState() => _BuildWorkoutDayScreenState();
}

class _BuildWorkoutDayScreenState extends State<BuildWorkoutDayScreen> {
  final _dayNameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _dayNumber = 1;
  bool _isRestDay = false;
  final Set<String> _muscleFocus = {'Chest'};
  final List<_ExerciseDraft> _exerciseDrafts = [];

  /// The selected muscles joined in the canonical [_muscles] order, e.g.
  /// "Chest, Back" — stored on the day's muscleGroupFocus field.
  String get _muscleFocusValue =>
      _muscles.where(_muscleFocus.contains).join(', ');
  String? _error;

  // Days already saved on the server (lets the coach edit/delete them).
  List<WorkoutDay> _existingDays = [];
  bool _loadingDays = true;
  bool _savedAny = false;
  // When set, the form is EDITING this saved day (PATCH) instead of adding.
  String? _editingDayId;

  static const _muscles = [
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Forearms',
    'Quads',
    'Hamstrings',
    'Glutes',
    'Calves',
    'Abs',
    'FullBody',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDays());
  }

  Future<void> _loadDays() async {
    final program =
        await context.read<WorkoutProvider>().fetchProgram(widget.programId);
    if (!mounted) return;
    setState(() {
      _existingDays = program?.days ?? [];
      _dayNumber = _existingDays.isEmpty
          ? 1
          : _existingDays.map((d) => d.dayNumber).reduce(max) + 1;
      _loadingDays = false;
    });
  }

  @override
  void dispose() {
    _dayNameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExercise() async {
    final ex = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(
          builder: (_) => const ExerciseLibraryScreen(selectionMode: true)),
    );
    if (ex != null) {
      setState(() => _exerciseDrafts.add(_ExerciseDraft(
            exerciseId: ex.id,
            nameEn: ex.nameEn,
            muscleGroup: ex.muscleGroup,
          )));
    }
  }

  List<Map<String, dynamic>> _exercisePayload() => _exerciseDrafts
      .map((e) => {
            'exerciseId': e.exerciseId,
            'sets': e.sets,
            'repsTarget': e.repsTarget,
            'restSeconds': e.restSeconds,
            if (e.weightKg != null) 'startingWeightKg': e.weightKg,
          })
      .toList();

  void _resetForm() {
    _editingDayId = null;
    _isRestDay = false;
    _dayNameCtrl.clear();
    _notesCtrl.clear();
    _exerciseDrafts.clear();
    _muscleFocus
      ..clear()
      ..add('Chest');
  }

  /// Load a saved day into the form for editing (PATCH on save).
  void _editDay(WorkoutDay d) {
    setState(() {
      _editingDayId = d.id;
      _error = null;
      _isRestDay = d.isRestDay;
      _dayNameCtrl.text = d.dayName;
      // muscleGroupFocus is stored as a comma-separated list of muscles.
      final parsed = d.muscleGroupFocus
          .split(',')
          .map((s) => s.trim())
          .where((s) => _muscles.contains(s))
          .toSet();
      _muscleFocus
        ..clear()
        ..addAll(parsed.isEmpty ? {'Chest'} : parsed);
      _notesCtrl.text = d.notes ?? '';
      _exerciseDrafts
        ..clear()
        ..addAll(d.exercises.map(_ExerciseDraft.fromItem));
    });
  }

  Future<void> _deleteDay(WorkoutDay d) async {
    final ok = await context.read<WorkoutProvider>().deleteWorkoutDay(d.id);
    if (!mounted) return;
    if (ok) {
      if (_editingDayId == d.id) setState(_resetForm);
      await _loadDays();
    }
  }

  Future<void> _saveDay() async {
    final l10n = AppLocalizations.of(context);
    if (_dayNameCtrl.text.trim().isEmpty) {
      setState(() => _error = l10n.dayNameRequired);
      return;
    }
    if (_exerciseDrafts.isEmpty) {
      setState(() => _error = l10n.addAtLeastOneExercise);
      return;
    }
    setState(() => _error = null);
    final provider = context.read<WorkoutProvider>();
    final name = _dayNameCtrl.text.trim();
    final notes =
        _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null;

    bool ok;
    if (_editingDayId != null) {
      // Update the already-saved day.
      ok = await provider.updateWorkoutDay(
        dayId: _editingDayId!,
        dayName: name,
        muscleGroupFocus: _muscleFocusValue,
        notes: notes,
        exercises: _isRestDay ? const [] : _exercisePayload(),
        isRestDay: _isRestDay,
      );
    } else {
      final id = await provider.addWorkoutDay(
        programId: widget.programId,
        dayNumber: _dayNumber,
        dayName: name,
        muscleGroupFocus: _muscleFocusValue,
        notes: notes,
        exercises: _isRestDay ? const [] : _exercisePayload(),
        isRestDay: _isRestDay,
      );
      ok = id != null;
    }

    if (ok && mounted) {
      final wasEditing = _editingDayId != null;
      setState(() {
        _savedAny = true;
        _resetForm();
      });
      await _loadDays();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(wasEditing ? AppLocalizations.of(context).dayUpdated : AppLocalizations.of(context).daySaved),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    }
  }

  void _finishProgram() {
    if (_existingDays.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).saveAtLeastOneDay);
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<WorkoutProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(widget.programName,
            style: TextStyle(
                fontWeight: FontWeight.w700, color: colors.fg, fontSize: 16)),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
        actions: [
          if (_existingDays.isNotEmpty)
            TextButton(
              onPressed: _finishProgram,
              child: Text(l10n.done,
                  style: const TextStyle(
                      color: AppColors.primaryColor1,
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Existing saved days — tap to edit, or delete.
            if (_loadingDays)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: const LiaqhPageLoader(),
              )
            else if (_existingDays.isNotEmpty) ...[
              Text(l10n.savedDays,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: colors.fg)),
              const SizedBox(height: 8),
              ..._existingDays.map((d) => _SavedDayTile(
                    day: d,
                    editing: _editingDayId == d.id,
                    colors: colors,
                    onEdit: () => _editDay(d),
                    onDelete: () => _deleteDay(d),
                  )),
              const Divider(height: 28),
            ],

            Text(
                _editingDayId != null
                    ? l10n.editDayTitle(_dayNameCtrl.text.isEmpty ? l10n.dayWord : _dayNameCtrl.text)
                    : l10n.dayNumber(_dayNumber),
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: colors.fg)),
            const SizedBox(height: 16),
            RoundTextField(
              textEditingController: _dayNameCtrl,
              hintText: l10n.dayNameHint,
              icon: 'assets/icons/user_icon.png',
              textInputType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            // Rest / break day toggle.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: colors.listTile,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bedtime_outlined,
                      color: AppColors.primaryColor1, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.restDay,
                            style: TextStyle(
                                color: colors.fg,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                        Text(l10n.restDayHint,
                            style:
                                TextStyle(color: colors.subFg, fontSize: 11)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isRestDay,
                    onChanged: (v) => setState(() => _isRestDay = v),
                  ),
                ],
              ),
            ),
            if (!_isRestDay) ...[
            const SizedBox(height: 16),
            Text(l10n.muscleFocus,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: colors.fg)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _muscles.map((m) {
                final selected = _muscleFocus.contains(m);
                return GestureDetector(
                  onTap: () => setState(() {
                    // Multi-select; keep at least one selected.
                    if (selected) {
                      if (_muscleFocus.length > 1) _muscleFocus.remove(m);
                    } else {
                      _muscleFocus.add(m);
                    }
                  }),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color:
                          selected ? AppColors.primaryColor1 : colors.listTile,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) ...[
                          const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                        ],
                        Text(m,
                            style: TextStyle(
                                color: selected ? Colors.white : colors.subFg,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Exercises
            Row(
              children: [
                Text(l10n.exercises,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: colors.fg)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickExercise,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(l10n.add),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor1),
                ),
              ],
            ),
            if (_exerciseDrafts.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.listTile,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: colors.divider, style: BorderStyle.solid),
                ),
                child: Center(
                  child: Text(l10n.noExercisesYet,
                      style: TextStyle(color: colors.subFg, fontSize: 13),
                      textAlign: TextAlign.center),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exerciseDrafts.length,
                onReorder: (old, next) {
                  setState(() {
                    final item = _exerciseDrafts.removeAt(old);
                    _exerciseDrafts.insert(next, item);
                  });
                },
                itemBuilder: (_, i) => _ExerciseDraftTile(
                  key: ValueKey(_exerciseDrafts[i].exerciseId + i.toString()),
                  draft: _exerciseDrafts[i],
                  index: i + 1,
                  onRemove: () => setState(() => _exerciseDrafts.removeAt(i)),
                  onChanged: () => setState(() {}),
                ),
              ),
            ],
            const SizedBox(height: 16),
            RoundTextField(
              textEditingController: _notesCtrl,
              hintText: l10n.notesOptional,
              icon: 'assets/icons/message_icon.png',
              textInputType: TextInputType.multiline,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.errorColor, fontSize: 13)),
            ],
            const SizedBox(height: 24),
            provider.loading
                ? const LiaqhPageLoader()
                : Column(
                    children: [
                      RoundGradientButton(
                        title: _editingDayId != null
                            ? l10n.updateDay
                            : l10n.saveDayAddAnother,
                        onPressed: _saveDay,
                      ),
                      if (_editingDayId != null) ...[
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => setState(_resetForm),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.subFg,
                            side: BorderSide(color: colors.divider),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(l10n.cancelEdit),
                        ),
                      ] else if (_existingDays.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _finishProgram,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryColor1,
                            side: const BorderSide(
                                color: AppColors.primaryColor1),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(l10n.finishDays(_existingDays.length)),
                        ),
                      ],
                    ],
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Saved day tile (edit / delete an already-saved day) ───────────────────────
class _SavedDayTile extends StatelessWidget {
  final WorkoutDay day;
  final bool editing;
  final AppThemeColors colors;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _SavedDayTile({
    required this.day,
    required this.editing,
    required this.colors,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: editing ? AppColors.primaryColor1 : colors.divider,
            width: editing ? 1.5 : 1),
      ),
      child: ListTile(
        dense: true,
        onTap: onEdit,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primaryColor1.withValues(alpha: 0.15),
          child: Text('${day.dayNumber}',
              style: const TextStyle(
                  color: AppColors.primaryColor1,
                  fontWeight: FontWeight.w800,
                  fontSize: 12)),
        ),
        title: Text(day.dayName,
            style: TextStyle(
                color: colors.fg, fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(
            '${day.muscleGroupFocus} · ${l10n.exercisesCountLabel(day.exercises.length)}',
            style: TextStyle(color: colors.subFg, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.primaryColor1),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: AppColors.errorColor),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Exercise draft model ──────────────────────────────────────────────────────
class _ExerciseDraft {
  final String exerciseId;
  final String nameEn;
  final String muscleGroup;
  int sets;
  String repsTarget;
  int restSeconds;
  double? weightKg;

  _ExerciseDraft({
    required this.exerciseId,
    required this.nameEn,
    required this.muscleGroup,
  })  : sets = 3,
        repsTarget = '8-12',
        restSeconds = 90,
        weightKg = null;

  /// Build a draft from an already-saved exercise (when editing a day).
  factory _ExerciseDraft.fromItem(WorkoutExerciseItem e) {
    final d = _ExerciseDraft(
        exerciseId: e.exerciseId,
        nameEn: e.exerciseNameEn,
        muscleGroup: e.muscleGroup);
    d.sets = e.sets;
    d.repsTarget = e.repsTarget;
    d.restSeconds = e.restSeconds;
    d.weightKg = e.startingWeightKg;
    return d;
  }
}

// ── Exercise draft tile ───────────────────────────────────────────────────────
class _ExerciseDraftTile extends StatelessWidget {
  final _ExerciseDraft draft;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _ExerciseDraftTile({
    Key? key,
    required this.draft,
    required this.index,
    required this.onRemove,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor1,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text('$index',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(draft.nameEn,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: colors.fg)),
                    Text(draft.muscleGroup,
                        style: TextStyle(fontSize: 11, color: colors.subFg)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    color: AppColors.errorColor, size: 18),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
              ),
              Icon(Icons.drag_handle, color: colors.subFg, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _NumberField(
                label: l10n.sets,
                value: draft.sets.toString(),
                onChanged: (v) {
                  draft.sets = int.tryParse(v) ?? draft.sets;
                  onChanged();
                },
              ),
              const SizedBox(width: 8),
              _TextField(
                label: l10n.reps,
                value: draft.repsTarget,
                hint: '8-12',
                onChanged: (v) {
                  draft.repsTarget = v.isEmpty ? draft.repsTarget : v;
                  onChanged();
                },
              ),
              const SizedBox(width: 8),
              _NumberField(
                label: l10n.restSeconds,
                value: draft.restSeconds.toString(),
                onChanged: (v) {
                  draft.restSeconds = int.tryParse(v) ?? draft.restSeconds;
                  onChanged();
                },
              ),
              const SizedBox(width: 8),
              _NumberField(
                label: l10n.weightKgOpt,
                value: draft.weightKg?.toString() ?? '',
                hint: 'opt',
                onChanged: (v) {
                  draft.weightKg = double.tryParse(v);
                  onChanged();
                },
                isDecimal: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final ValueChanged<String> onChanged;
  final bool isDecimal;

  const _NumberField({
    required this.label,
    required this.value,
    this.hint,
    required this.onChanged,
    this.isDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: colors.subFg,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            onChanged: onChanged,
            keyboardType: isDecimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: colors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final ValueChanged<String> onChanged;

  const _TextField({
    required this.label,
    required this.value,
    this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: colors.subFg,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            onChanged: onChanged,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: colors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
