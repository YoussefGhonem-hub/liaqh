import 'package:fitnessapp/data/models/meal_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/meal_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:fitnessapp/utils/nutrition_l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'food_library_screen.dart';

class AddMealScreen extends StatefulWidget {
  final String planId;
  final String dayId;
  final String traineeName;

  /// When set, this screen replaces an existing (rejected) meal's contents
  /// instead of adding a new meal — the trainee is then notified.
  final String? replaceMealId;
  final String? initialMealType;

  const AddMealScreen({
    Key? key,
    required this.planId,
    required this.dayId,
    required this.traineeName,
    this.replaceMealId,
    this.initialMealType,
  }) : super(key: key);

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  late String _mealType;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  final _notesCtrl = TextEditingController();
  final List<FoodItemDraft> _items = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _mealType = widget.initialMealType != null &&
            _mealTypes.contains(widget.initialMealType)
        ? widget.initialMealType!
        : 'Breakfast';
  }

  bool get _isReplace => widget.replaceMealId != null;

  static const _mealTypes = [
    'Breakfast',
    'MidMorning',
    'Lunch',
    'Afternoon',
    'Dinner',
    'PreWorkout',
    'PostWorkout',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor1, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _time = t);
  }

  Future<void> _addFood() async {
    final draft = await Navigator.push<FoodItemDraft>(
      context,
      MaterialPageRoute(
        builder: (_) => const FoodLibraryScreen(selectionMode: true),
      ),
    );
    if (draft != null) {
      setState(() => _items.add(draft));
    }
  }

  double get _totalCalories =>
      _items.fold(0, (s, d) => s + d.calories);
  double get _totalProtein =>
      _items.fold(0, (s, d) => s + d.protein);
  double get _totalCarbs =>
      _items.fold(0, (s, d) => s + d.carbs);
  double get _totalFat =>
      _items.fold(0, (s, d) => s + d.fat);

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_items.isEmpty) {
      setState(() => _error = l10n.addAtLeastOneFood);
      return;
    }
    setState(() => _error = null);

    final provider = context.read<MealProvider>();
    final bool ok;
    if (_isReplace) {
      ok = await provider.replaceMeal(
        mealId: widget.replaceMealId!,
        planId: widget.planId,
        timeOfDay: _formatTime(_time),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        foodItems: _items.map((d) => d.toJson()).toList(),
      );
    } else {
      ok = await provider.addMeal(
        planId: widget.planId,
        dayId: widget.dayId,
        mealType: _mealType,
        timeOfDay: _formatTime(_time),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        foodItems: _items.map((d) => d.toJson()).toList(),
      );
    }

    if (ok && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<MealProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(
          _isReplace ? l10n.replaceMeal : l10n.addMealTitle(widget.traineeName),
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.fg,
              fontSize: 16),
        ),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Meal type chips ──────────────────────────────────────
                  Text(
                    l10n.mealType,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: colors.fg),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mealTypes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final type = _mealTypes[i];
                        final selected = _mealType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _mealType = type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryColor1
                                  : colors.listTile,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              mealTypeLabel(l10n, type),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : colors.subFg,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Time picker ──────────────────────────────────────────
                  Text(
                    l10n.time,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: colors.fg),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.listTile,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_outlined,
                              color: AppColors.primaryColor1, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            _time.format(context),
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colors.fg,
                                fontSize: 14),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_forward_ios,
                              size: 14, color: colors.subFg),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Notes ────────────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                        color: colors.listTile,
                        borderRadius: BorderRadius.circular(15)),
                    child: TextField(
                      controller: _notesCtrl,
                      keyboardType: TextInputType.multiline,
                      maxLines: 2,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 15),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: l10n.notesOptional,
                        hintStyle: TextStyle(
                            fontSize: 12, color: colors.subFg),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Add food button ──────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.foodItems,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: colors.fg),
                      ),
                      TextButton.icon(
                        onPressed: _addFood,
                        icon: const Icon(Icons.add_circle_outline,
                            color: AppColors.primaryColor1, size: 18),
                        label: Text(
                          l10n.addFood,
                          style: const TextStyle(
                              color: AppColors.primaryColor1,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),

                  // ── Food items list ──────────────────────────────────────
                  if (_items.isEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          l10n.noFoodsAdded,
                          style: TextStyle(
                              color: colors.subFg.withValues(alpha: 0.7),
                              fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...List.generate(
                      _items.length,
                      (i) => _FoodItemRow(
                        draft: _items[i],
                        onGramsChanged: (g) {
                          setState(() => _items[i].grams = g);
                        },
                        onDelete: () {
                          setState(() => _items.removeAt(i));
                        },
                      ),
                    ),

                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!,
                        style: const TextStyle(
                            color: AppColors.errorColor, fontSize: 13)),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Live totals bar + submit ────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: colors.card,
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                // Totals
                if (_items.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _TotalChip(
                          label: '🔥 ${_totalCalories.toStringAsFixed(0)} kcal',
                          color: AppColors.primaryColor1),
                      _TotalChip(
                          label: 'P ${_totalProtein.toStringAsFixed(1)}g',
                          color: const Color(0xFFE53935)),
                      _TotalChip(
                          label: 'C ${_totalCarbs.toStringAsFixed(1)}g',
                          color: const Color(0xFF2196F3)),
                      _TotalChip(
                          label: 'F ${_totalFat.toStringAsFixed(1)}g',
                          color: const Color(0xFFFFC107)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                provider.loading
                    ? const LiaqhPageLoader()
                    : RoundGradientButton(
                        title: _isReplace ? l10n.replaceMeal : l10n.saveMeal,
                        onPressed: _submit,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Food item row ──────────────────────────────────────────────────────────────

class _FoodItemRow extends StatefulWidget {
  final FoodItemDraft draft;
  final ValueChanged<double> onGramsChanged;
  final VoidCallback onDelete;

  const _FoodItemRow({
    required this.draft,
    required this.onGramsChanged,
    required this.onDelete,
  });

  @override
  State<_FoodItemRow> createState() => _FoodItemRowState();
}

class _FoodItemRowState extends State<_FoodItemRow> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.draft.grams.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final d = widget.draft;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  d.food.nameEn,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: colors.fg),
                ),
              ),
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _ctrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  style: const TextStyle(fontSize: 13),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                    suffixText: 'g',
                    filled: true,
                    fillColor: colors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) {
                    final g = double.tryParse(v) ?? d.grams;
                    widget.onGramsChanged(g);
                  },
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.errorColor, size: 20),
                onPressed: widget.onDelete,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _MiniMacro(
                  label: '${d.calories.toStringAsFixed(0)} kcal',
                  color: AppColors.primaryColor1),
              const SizedBox(width: 6),
              _MiniMacro(
                  label: 'P ${d.protein.toStringAsFixed(1)}g',
                  color: const Color(0xFFE53935)),
              const SizedBox(width: 6),
              _MiniMacro(
                  label: 'C ${d.carbs.toStringAsFixed(1)}g',
                  color: const Color(0xFF2196F3)),
              const SizedBox(width: 6),
              _MiniMacro(
                  label: 'F ${d.fat.toStringAsFixed(1)}g',
                  color: const Color(0xFFFFC107)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniMacro({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TotalChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w700)),
    );
  }
}
