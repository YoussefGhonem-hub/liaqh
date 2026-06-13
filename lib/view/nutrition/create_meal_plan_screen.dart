import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/meal_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/common_widgets/round_textfield.dart';
import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'build_meal_plan_screen.dart';

class CreateMealPlanScreen extends StatefulWidget {
  final String traineeId;
  final String traineeName;

  const CreateMealPlanScreen({
    Key? key,
    required this.traineeId,
    required this.traineeName,
  }) : super(key: key);

  @override
  State<CreateMealPlanScreen> createState() => _CreateMealPlanScreenState();
}

class _CreateMealPlanScreenState extends State<CreateMealPlanScreen> {
  final _nameCtrl     = TextEditingController();
  final _caloriesCtrl = TextEditingController(text: '2000');
  final _proteinCtrl  = TextEditingController(text: '150');
  final _carbsCtrl    = TextEditingController(text: '200');
  final _fatCtrl      = TextEditingController(text: '65');

  DateTime _weekStart = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _weekStart,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor1, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _weekStart = d);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = l10n.planNameRequired);
      return;
    }
    setState(() => _error = null);

    final provider = context.read<MealProvider>();
    final id = await provider.createPlan(
      traineeId: widget.traineeId,
      name: _nameCtrl.text.trim(),
      weekStartDate:
          '${_weekStart.year}-${_weekStart.month.toString().padLeft(2, '0')}-${_weekStart.day.toString().padLeft(2, '0')}',
      targetCalories: int.tryParse(_caloriesCtrl.text) ?? 2000,
      targetProtein: int.tryParse(_proteinCtrl.text) ?? 150,
      targetCarbs: int.tryParse(_carbsCtrl.text) ?? 200,
      targetFat: int.tryParse(_fatCtrl.text) ?? 65,
    );

    if (id != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BuildMealPlanScreen(
            planId: id,
            traineeName: widget.traineeName,
          ),
        ),
      );
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
          l10n.newMealPlan(widget.traineeName),
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.fg,
              fontSize: 16),
        ),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryColor1.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primaryColor1.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.primaryColor1, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.suggestedTargets,
                      style: TextStyle(
                          fontSize: 12,
                          color: colors.subFg,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Plan name
            RoundTextField(
              textEditingController: _nameCtrl,
              hintText: l10n.planNameHint,
              icon: 'assets/icons/user_icon.png',
              textInputType: TextInputType.text,
            ),
            const SizedBox(height: 20),

            // Week start date
            Text(
              l10n.weekStartDate,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: colors.fg),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: colors.listTile,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.primaryColor1, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      '${_weekStart.day.toString().padLeft(2, '0')}/'
                      '${_weekStart.month.toString().padLeft(2, '0')}/'
                      '${_weekStart.year}',
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
            const SizedBox(height: 24),

            // Macro targets
            Text(
              l10n.dailyMacroTargets,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: colors.fg),
            ),
            const SizedBox(height: 12),

            _MacroField(
              ctrl: _caloriesCtrl,
              label: l10n.caloriesKcal,
              icon: Icons.local_fire_department_outlined,
              iconColor: AppColors.primaryColor1,
            ),
            const SizedBox(height: 12),
            _MacroField(
              ctrl: _proteinCtrl,
              label: l10n.proteinG,
              icon: Icons.set_meal_outlined,
              iconColor: const Color(0xFFE53935),
            ),
            const SizedBox(height: 12),
            _MacroField(
              ctrl: _carbsCtrl,
              label: l10n.carbsG,
              icon: Icons.breakfast_dining_outlined,
              iconColor: const Color(0xFF2196F3),
            ),
            const SizedBox(height: 12),
            _MacroField(
              ctrl: _fatCtrl,
              label: l10n.fatG,
              icon: Icons.water_drop_outlined,
              iconColor: const Color(0xFFFFC107),
            ),
            const SizedBox(height: 24),

            // Suggested targets card
            const _SuggestedTargets(),
            const SizedBox(height: 24),

            // Error
            if (_error != null) ...[
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.errorColor, fontSize: 13)),
              const SizedBox(height: 12),
            ],

            // Submit
            provider.loading
                ? const Center(child: CircularProgressIndicator())
                : RoundGradientButton(
                    title: l10n.createPlanAndBuild,
                    onPressed: _submit,
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Macro field helper ─────────────────────────────────────────────────────────

class _MacroField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _MacroField({
    required this.ctrl,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
          color: colors.listTile,
          borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: label,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          hintStyle:
              TextStyle(fontSize: 12, color: colors.subFg),
        ),
      ),
    );
  }
}

// ── Suggested targets card ─────────────────────────────────────────────────────

class _SuggestedTargets extends StatelessWidget {
  const _SuggestedTargets();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.listTile,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.suggestedTargets,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: colors.fg),
          ),
          const SizedBox(height: 12),
          _SuggestionRow(
            goal: l10n.cut,
            emoji: '📉',
            color: AppColors.errorColor,
            values: '1800 kcal / 160g P / 150g C / 55g F',
          ),
          const SizedBox(height: 8),
          _SuggestionRow(
            goal: l10n.maintain,
            emoji: '⚖️',
            color: AppColors.warningColor,
            values: '2200 kcal / 150g P / 220g C / 65g F',
          ),
          const SizedBox(height: 8),
          _SuggestionRow(
            goal: l10n.bulk,
            emoji: '📈',
            color: AppColors.successColor,
            values: '2800 kcal / 180g P / 300g C / 80g F',
          ),
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  final String goal;
  final String emoji;
  final Color color;
  final String values;

  const _SuggestionRow({
    required this.goal,
    required this.emoji,
    required this.color,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$emoji $goal',
            style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            values,
            style: TextStyle(
                fontSize: 11,
                color: colors.subFg,
                height: 1.5),
          ),
        ),
      ],
    );
  }
}
