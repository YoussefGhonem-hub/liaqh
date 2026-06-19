import 'package:fitnessapp/common_widgets/attachments_view.dart';
import 'package:fitnessapp/data/models/meal_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/meal_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/utils/nutrition_l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MealPlanViewScreen extends StatelessWidget {
  final MealPlan plan;
  final String traineeId;

  /// When true (the trainee viewing their own plan) each meal shows a Reject
  /// action and file-based plans offer a whole-plan reject.
  final bool canReject;

  const MealPlanViewScreen({
    Key? key,
    required this.plan,
    required this.traineeId,
    this.canReject = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    // File-based plan → show the uploaded document instead of day tabs.
    if (plan.isFile) {
      return Scaffold(
        backgroundColor: colors.bg,
        appBar: AppBar(
          title: Text(plan.name,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: colors.fg, fontSize: 16)),
          backgroundColor: colors.bg,
          elevation: 0,
          foregroundColor: colors.fg,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.coachProvidedFilePlan(plan.durationMonths),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AttachmentsView(urls: [plan.attachmentUrl!]),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: plan.days.length,
      child: Scaffold(
        backgroundColor: colors.bg,
        appBar: AppBar(
          title: Text(
            plan.name,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.fg,
                fontSize: 16),
          ),
          backgroundColor: colors.bg,
          elevation: 0,
          foregroundColor: colors.fg,
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.primaryColor1,
            unselectedLabelColor: colors.subFg,
            indicatorColor: AppColors.primaryColor1,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            tabs: plan.days
                .map((d) => Tab(text: dayShortName(context, d.dayOfWeek)))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: plan.days
              .map((d) => _DayViewTab(
                  day: d, traineeId: traineeId, canReject: canReject))
              .toList(),
        ),
      ),
    );
  }
}

// ── Day view tab ───────────────────────────────────────────────────────────────

class _DayViewTab extends StatelessWidget {
  final MealPlanDay day;
  final String traineeId;
  final bool canReject;

  const _DayViewTab(
      {required this.day, required this.traineeId, this.canReject = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // Day totals summary row
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: colors.listTile,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DaySummaryChip(
                  label: '🔥 ${day.totalCalories.toStringAsFixed(0)} kcal',
                  color: AppColors.primaryColor1),
              _DaySummaryChip(
                  label: '🥩 ${day.totalProtein.toStringAsFixed(1)}g',
                  color: const Color(0xFFE53935)),
              _DaySummaryChip(
                  label: '🍞 ${day.totalCarbs.toStringAsFixed(1)}g',
                  color: const Color(0xFF2196F3)),
              _DaySummaryChip(
                  label: '🫙 ${day.totalFat.toStringAsFixed(1)}g',
                  color: const Color(0xFFFFC107)),
            ],
          ),
        ),
        if (day.meals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(l10n.noMealsToday,
                  style: TextStyle(color: colors.subFg)),
            ),
          )
        else
          ...day.meals.map(
            (m) => _MealViewCard(
                meal: m, traineeId: traineeId, canReject: canReject),
          ),
      ],
    );
  }
}

class _DaySummaryChip extends StatelessWidget {
  final String label;
  final Color color;
  const _DaySummaryChip({required this.label, required this.color});

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

// ── Meal view card ─────────────────────────────────────────────────────────────

class _MealViewCard extends StatelessWidget {
  final Meal meal;
  final String traineeId;
  final bool canReject;

  const _MealViewCard(
      {required this.meal, required this.traineeId, this.canReject = false});

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _LogBottomSheet(
        meal: meal,
        traineeId: traineeId,
      ),
    );
  }

  Future<void> _showRejectDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final colors = ctx.colors;
        return AlertDialog(
          backgroundColor: colors.bg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          title: Text(l10n.rejectThisMeal,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: colors.fg)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.rejectReasonHint,
                style: TextStyle(fontSize: 12, color: colors.subFg),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                maxLines: 3,
                style: TextStyle(color: colors.fg, fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n.rejectReasonPlaceholder,
                  hintStyle: TextStyle(color: colors.subFg, fontSize: 12),
                  filled: true,
                  fillColor: colors.listTile,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor,
                  foregroundColor: Colors.white),
              child: Text(l10n.reject),
            ),
          ],
        );
      },
    );

    if (reason == null || reason.isEmpty || !context.mounted) return;
    final ok = await context.read<MealProvider>().rejectMeal(
          mealId: meal.id,
          reason: reason,
          traineeId: traineeId,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              ok ? l10n.mealRejectedNotified : l10n.couldNotReject),
          backgroundColor:
              ok ? AppColors.successColor : AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
                        mealTypeLabel(l10n, meal.mealType),
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
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showLogSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor1,
                          AppColors.primaryColor2
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(
                      l10n.log,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ),
                ),
                if (canReject && !meal.isRejected) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _showRejectDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.errorColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.thumb_down_alt_outlined,
                          size: 16, color: AppColors.errorColor),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Rejected banner
          if (meal.isRejected)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.errorColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.report_problem_outlined,
                      size: 16, color: AppColors.errorColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.rejectedWaitingCoach,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.errorColor)),
                        if (meal.rejectionReason != null &&
                            meal.rejectionReason!.isNotEmpty)
                          Text('“${meal.rejectionReason!}”',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.errorColor)),
                      ],
                    ),
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
                        '${f.foodNameEn} • ${f.weightGrams.toStringAsFixed(0)}g • '
                        '${f.caloriesCalculated.toStringAsFixed(0)} kcal / '
                        'P ${f.proteinCalculated.toStringAsFixed(1)}g / '
                        'C ${f.carbsCalculated.toStringAsFixed(1)}g / '
                        'F ${f.fatCalculated.toStringAsFixed(1)}g',
                        style: TextStyle(
                            fontSize: 11, color: colors.subFg),
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

// ── Log bottom sheet ───────────────────────────────────────────────────────────

class _LogBottomSheet extends StatelessWidget {
  final Meal meal;
  final String traineeId;

  const _LogBottomSheet({required this.meal, required this.traineeId});

  Future<void> _log(BuildContext context, String status) async {
    Navigator.pop(context);
    final l10n = AppLocalizations.of(context);
    final ok = await context.read<MealProvider>().logMeal(
          traineeId: traineeId,
          mealId: meal.id,
          status: status,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? l10n.mealLoggedAs(status)
              : l10n.failedToLog),
          backgroundColor: ok
              ? AppColors.successColor
              : AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.listTile,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.logMeal(mealTypeLabel(l10n, meal.mealType)),
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: colors.fg),
          ),
          const SizedBox(height: 20),
          _LogOption(
            label: l10n.completed,
            subtitle: l10n.completedHint,
            color: AppColors.successColor,
            onTap: () => _log(context, 'Completed'),
          ),
          const SizedBox(height: 10),
          _LogOption(
            label: l10n.skipped,
            subtitle: l10n.skippedHint,
            color: AppColors.errorColor,
            onTap: () => _log(context, 'Skipped'),
          ),
          const SizedBox(height: 10),
          _LogOption(
            label: l10n.partial,
            subtitle: l10n.partialHint,
            color: AppColors.warningColor,
            onTap: () => _log(context, 'Partial'),
          ),
        ],
      ),
    );
  }
}

class _LogOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _LogOption({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: color)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11, color: colors.subFg)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
