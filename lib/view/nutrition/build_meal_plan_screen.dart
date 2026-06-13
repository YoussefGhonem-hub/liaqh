import 'package:fitnessapp/data/models/meal_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/meal_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_meal_screen.dart';
import 'meal_plan_view_screen.dart';
import 'shopping_list_screen.dart';

class BuildMealPlanScreen extends StatefulWidget {
  final String planId;
  final String traineeName;

  const BuildMealPlanScreen({
    Key? key,
    required this.planId,
    required this.traineeName,
  }) : super(key: key);

  @override
  State<BuildMealPlanScreen> createState() => _BuildMealPlanScreenState();
}

class _BuildMealPlanScreenState extends State<BuildMealPlanScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _tabCount = 7;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MealProvider>();
      if (provider.currentPlan == null ||
          provider.currentPlan!.id != widget.planId) {
        _loadPlan();
      } else {
        _syncTabController(provider.currentPlan!);
      }
    });
  }

  Future<void> _loadPlan() async {
    // currentPlan was already set in createPlan().
  }

  void _syncTabController(MealPlan plan) {
    final count = plan.days.isNotEmpty ? plan.days.length : 7;
    if (count != _tabCount) {
      setState(() {
        _tabCount = count;
        _tabController?.dispose();
        _tabController = TabController(length: _tabCount, vsync: this);
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<MealProvider>();
    final l10n = AppLocalizations.of(context);
    final plan = provider.currentPlan;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(
          '${l10n.mealPlans} — ${widget.traineeName}',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.fg,
              fontSize: 16),
        ),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
        actions: [
          if (plan != null)
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MealPlanViewScreen(
                    plan: plan,
                    traineeId: widget.planId,
                  ),
                ),
              ),
              child: Text(
                l10n.viewPlan,
                style: const TextStyle(
                    color: AppColors.primaryColor1,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShoppingListScreen(planId: widget.planId),
          ),
        ),
        icon: const Icon(Icons.shopping_cart_outlined),
        label: Text(l10n.shoppingList),
        backgroundColor: AppColors.primaryColor1,
        foregroundColor: Colors.white,
      ),
      body: provider.loading && plan == null
          ? const Center(child: CircularProgressIndicator())
          : plan == null
              ? Center(
                  child: Text(l10n.noMealPlanLoaded,
                      style: TextStyle(color: colors.subFg)))
              : Column(
                  children: [
                    // Macro target header
                    _MacroHeader(plan: plan),
                    // Day tabs
                    Container(
                      color: colors.bg,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: AppColors.primaryColor1,
                        unselectedLabelColor: colors.subFg,
                        indicatorColor: AppColors.primaryColor1,
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 12),
                        tabs: plan.days
                            .map((d) => Tab(text: d.dayName.substring(0, 3)))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: plan.days
                            .map((d) => _DayPanel(
                                  day: d,
                                  planId: widget.planId,
                                  traineeName: widget.traineeName,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
    );
  }
}

// ── Macro header ───────────────────────────────────────────────────────────────

class _MacroHeader extends StatelessWidget {
  final MealPlan plan;
  const _MacroHeader({required this.plan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = plan.days.isEmpty ? 1 : plan.days.length;
    final avgCal  = plan.totalWeekCalories / days;
    final avgProt = plan.totalWeekProtein  / days;
    final avgCarb = plan.totalWeekCarbs    / days;
    final avgFat  = plan.totalWeekFat      / days;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor1.withValues(alpha: 0.92),
            AppColors.primaryColor2.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          _MacroBar(
            label: l10n.calories,
            actual: avgCal,
            target: plan.targetCalories.toDouble(),
            unit: 'kcal',
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MacroBar(
                  label: l10n.protein,
                  actual: avgProt,
                  target: plan.targetProteinGrams.toDouble(),
                  unit: 'g',
                  color: const Color(0xFFFFCDD2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroBar(
                  label: l10n.carbs,
                  actual: avgCarb,
                  target: plan.targetCarbsGrams.toDouble(),
                  unit: 'g',
                  color: const Color(0xFFBBDEFB),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroBar(
                  label: l10n.fat,
                  actual: avgFat,
                  target: plan.targetFatGrams.toDouble(),
                  unit: 'g',
                  color: const Color(0xFFFFF9C4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double actual;
  final double target;
  final String unit;
  final Color color;

  const _MacroBar({
    required this.label,
    required this.actual,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0
        ? (actual / target).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color)),
            Text(
              '${actual.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit',
              style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.85)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.25),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ── Day panel ──────────────────────────────────────────────────────────────────

class _DayPanel extends StatelessWidget {
  final MealPlanDay day;
  final String planId;
  final String traineeName;

  const _DayPanel({
    required this.day,
    required this.planId,
    required this.traineeName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Day totals row
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: colors.listTile,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayMacroChip(
                  label: '🔥 ${day.totalCalories.toStringAsFixed(0)} kcal',
                  color: AppColors.primaryColor1),
              _DayMacroChip(
                  label: '🥩 ${day.totalProtein.toStringAsFixed(1)}g',
                  color: const Color(0xFFE53935)),
              _DayMacroChip(
                  label: '🍞 ${day.totalCarbs.toStringAsFixed(1)}g',
                  color: const Color(0xFF2196F3)),
              _DayMacroChip(
                  label: '🫙 ${day.totalFat.toStringAsFixed(1)}g',
                  color: const Color(0xFFFFC107)),
            ],
          ),
        ),
        // Meals list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              ...day.meals.map((m) => _MealCard(
                    meal: m,
                    planId: planId,
                    dayId: day.id,
                  )),
              const SizedBox(height: 12),
              // Add meal button
              OutlinedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMealScreen(
                        planId: planId,
                        dayId: day.id,
                        traineeName: traineeName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add,
                    color: AppColors.primaryColor1, size: 18),
                label: Text(l10n.addMeal,
                    style: const TextStyle(
                        color: AppColors.primaryColor1,
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: AppColors.primaryColor1, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayMacroChip extends StatelessWidget {
  final String label;
  final Color color;
  const _DayMacroChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Meal card ──────────────────────────────────────────────────────────────────

class _MealCard extends StatelessWidget {
  final Meal meal;
  final String planId;
  final String dayId;

  const _MealCard({
    required this.meal,
    required this.planId,
    required this.dayId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Text(meal.mealTypeEmoji,
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.mealType,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: colors.fg),
                      ),
                      if (meal.timeOfDay != null)
                        Text(
                          meal.timeOfDay!.length >= 5
                              ? meal.timeOfDay!.substring(0, 5)
                              : meal.timeOfDay!,
                          style: TextStyle(
                              fontSize: 11, color: colors.subFg),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor1.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${meal.totalCalories.toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryColor1,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.errorColor, size: 20),
                  onPressed: () async {
                    final ok = await context.read<MealProvider>().removeMeal(
                          planId: planId,
                          dayId: dayId,
                          mealId: meal.id,
                        );
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.mealRemoved)),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          // Food items
          if (meal.foodItems.isNotEmpty) ...[
            Divider(height: 1, thickness: 1, color: colors.divider),
            ...meal.foodItems.map(
              (f) => Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                child: Row(
                  children: [
                    Icon(Icons.circle,
                        size: 6, color: colors.subFg),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${f.foodNameEn} • ${f.weightGrams.toStringAsFixed(0)}g • ${f.caloriesCalculated.toStringAsFixed(0)} kcal',
                        style: TextStyle(
                            fontSize: 12, color: colors.subFg),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
