import 'dart:async';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/data/models/workout_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/workout_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/utils/muscle_group_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_custom_exercise_screen.dart';

/// Used in two modes:
///   1. browse-only (selectionMode = false) — view exercise library, FAB to add custom
///   2. select-mode (selectionMode = true)  — returns selected Exercise via Navigator.pop
class ExerciseLibraryScreen extends StatefulWidget {
  static const routeName = '/ExerciseLibraryScreen';
  final bool selectionMode;

  const ExerciseLibraryScreen({Key? key, this.selectionMode = false}) : super(key: key);

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedMuscle;
  Timer? _debounce;

  static const _muscleGroups = [
    'All', 'Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps',
    'Forearms', 'Quads', 'Hamstrings', 'Glutes', 'Calves', 'Abs', 'FullBody',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<WorkoutProvider>().loadExercises());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<WorkoutProvider>().loadExercises(
            search: val.isEmpty ? null : val,
            muscleGroup: _selectedMuscle == 'All' ? null : _selectedMuscle,
          );
    });
  }

  void _onMuscleFilter(String? muscle) {
    setState(() => _selectedMuscle = muscle == 'All' ? null : muscle);
    context.read<WorkoutProvider>().loadExercises(
          search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
          muscleGroup: muscle == 'All' ? null : muscle,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<WorkoutProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(
          widget.selectionMode ? l10n.selectExercise : l10n.exerciseLibrary,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.fg,
              fontSize: 17),
        ),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
      ),
      // Available in both browse and selection mode: the coach can create a
      // custom exercise on the spot if it isn't in the library.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCustomExerciseScreen()),
        ).then((_) => context.read<WorkoutProvider>().loadExercises()),
        icon: const Icon(Icons.add),
        label: Text(l10n.addCustom),
        backgroundColor: AppColors.primaryColor1,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: l10n.searchExercises,
                prefixIcon: Icon(Icons.search, color: colors.subFg),
                filled: true,
                fillColor: colors.listTile,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _muscleGroups.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final g = _muscleGroups[i];
                final selected = (_selectedMuscle ?? 'All') == g;
                return FilterChip(
                  label: Text(g, style: TextStyle(
                    fontSize: 12,
                    color: selected ? AppColors.primaryColor1 : colors.subFg,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  )),
                  selected: selected,
                  onSelected: (_) => _onMuscleFilter(g),
                  selectedColor: AppColors.primaryColor1.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primaryColor1,
                  backgroundColor: colors.listTile,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  side: BorderSide.none,
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: provider.loading
                ? const LiaqhPageLoader()
                : provider.exercises.isEmpty
                    ? Center(
                        child: Text(l10n.noExercisesFound,
                            style: TextStyle(color: colors.subFg)))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: provider.exercises.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _ExerciseTile(
                          exercise: provider.exercises[i],
                          selectionMode: widget.selectionMode,
                          onTap: widget.selectionMode
                              ? () => Navigator.pop(context, provider.exercises[i])
                              : null,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final bool selectionMode;
  final VoidCallback? onTap;
  const _ExerciseTile(
      {required this.exercise,
      required this.selectionMode,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final style = muscleGroupStyle(exercise.muscleGroup);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.listTile,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Animated gradient icon tile
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: style.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: exercise.listImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        exercise.listImage!,
                        fit: BoxFit.cover,
                        width: 52,
                        height: 52,
                        errorBuilder: (_, __, ___) => Icon(
                            style.icon,
                            color: Colors.white,
                            size: 26),
                      ))
                  : Icon(style.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.nameEn,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: colors.fg)),
                  if (exercise.nameAr.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(exercise.nameAr,
                        style: TextStyle(
                            fontSize: 11,
                            color: colors.subFg)),
                  ],
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      MuscleGroupBadge(muscleGroup: exercise.muscleGroup),
                      if (exercise.equipment != null)
                        _tag(exercise.equipment!),
                      if (exercise.isCustom)
                        _tag(l10n.custom, color: AppColors.primaryColor1),
                    ],
                  ),
                ],
              ),
            ),
            if (selectionMode)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: style.gradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add,
                    color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, {Color? color}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: (color ?? AppColors.grayColor).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 10,
                color: color ?? AppColors.grayColor,
                fontWeight: FontWeight.w600)),
      );
}
