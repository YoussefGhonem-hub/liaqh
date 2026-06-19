import 'dart:io';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';

import 'package:file_picker/file_picker.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/meal_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/utils/nutrition_calculator.dart';
import 'package:fitnessapp/common_widgets/round_textfield.dart';
import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'build_meal_plan_screen.dart';

/// How the coach builds the plan: meal-by-meal inside the app, or by uploading
/// a ready-made file (PDF / image).
enum _PlanMode { build, upload }

String _goalLabel(AppLocalizations l10n, FitnessGoal g) {
  switch (g) {
    case FitnessGoal.cut:
      return l10n.goalCut;
    case FitnessGoal.bulk:
      return l10n.goalBulk;
    case FitnessGoal.maintain:
      return l10n.goalMaintain;
    case FitnessGoal.recomp:
      return l10n.goalRecomp;
  }
}

String _activityLabel(AppLocalizations l10n, ActivityLevel a) {
  switch (a) {
    case ActivityLevel.sedentary:
      return l10n.activitySedentary;
    case ActivityLevel.light:
      return l10n.activityLight;
    case ActivityLevel.moderate:
      return l10n.activityModerate;
    case ActivityLevel.active:
      return l10n.activityActive;
    case ActivityLevel.veryActive:
      return l10n.activityVeryActive;
  }
}

String _activityHint(AppLocalizations l10n, ActivityLevel a) {
  switch (a) {
    case ActivityLevel.sedentary:
      return l10n.activitySedentaryHint;
    case ActivityLevel.light:
      return l10n.activityLightHint;
    case ActivityLevel.moderate:
      return l10n.activityModerateHint;
    case ActivityLevel.active:
      return l10n.activityActiveHint;
    case ActivityLevel.veryActive:
      return l10n.activityVeryActiveHint;
  }
}

class CreateMealPlanScreen extends StatefulWidget {
  final String traineeId;
  final String traineeName;
  final double heightCm;
  final double currentWeightKg;
  final String goal;

  const CreateMealPlanScreen({
    Key? key,
    required this.traineeId,
    required this.traineeName,
    this.heightCm = 0,
    this.currentWeightKg = 0,
    this.goal = 'Maintain',
  }) : super(key: key);

  @override
  State<CreateMealPlanScreen> createState() => _CreateMealPlanScreenState();
}

class _CreateMealPlanScreenState extends State<CreateMealPlanScreen> {
  final _nameCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController(text: '2000');
  final _proteinCtrl = TextEditingController(text: '150');
  final _carbsCtrl = TextEditingController(text: '200');
  final _fatCtrl = TextEditingController(text: '65');

  // Calculator inputs (sex + activity aren't stored on the trainee record, so
  // the coach picks them inline; height/weight come from the trainee profile).
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  final _ageCtrl = TextEditingController(text: '25');
  Sex _sex = Sex.male;
  ActivityLevel _activity = ActivityLevel.moderate;
  late FitnessGoal _goal;

  _PlanMode _mode = _PlanMode.build;
  DateTime _weekStart = DateTime.now();
  int _durationMonths = 1;
  File? _pickedFile;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _heightCtrl = TextEditingController(
        text: widget.heightCm > 0 ? widget.heightCm.toStringAsFixed(0) : '');
    _weightCtrl = TextEditingController(
        text: widget.currentWeightKg > 0
            ? widget.currentWeightKg.toStringAsFixed(0)
            : '');
    _goal = FitnessGoalX.fromString(widget.goal);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  NutritionTargets? get _targets {
    final h = double.tryParse(_heightCtrl.text) ?? 0;
    final w = double.tryParse(_weightCtrl.text) ?? 0;
    final age = int.tryParse(_ageCtrl.text) ?? 0;
    if (h <= 0 || w <= 0 || age <= 0) return null;
    return NutritionTargets.compute(
      sex: _sex,
      weightKg: w,
      heightCm: h,
      age: age,
      activity: _activity,
      goal: _goal,
    );
  }

  void _applyTargets() {
    final t = _targets;
    if (t == null) return;
    setState(() {
      _caloriesCtrl.text = '${t.calories}';
      _proteinCtrl.text = '${t.proteinGrams}';
      _carbsCtrl.text = '${t.carbsGrams}';
      _fatCtrl.text = '${t.fatGrams}';
    });
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

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );
    if (res != null && res.files.single.path != null) {
      setState(() => _pickedFile = File(res.files.single.path!));
    }
  }

  String get _weekStartString =>
      '${_weekStart.year}-${_weekStart.month.toString().padLeft(2, '0')}-${_weekStart.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = l10n.planNameRequired);
      return;
    }
    if (_mode == _PlanMode.upload && _pickedFile == null) {
      setState(() => _error = l10n.chooseFileToUpload);
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });

    final provider = context.read<MealProvider>();

    String? attachmentUrl;
    if (_mode == _PlanMode.upload) {
      attachmentUrl = await provider.uploadPlanFile(_pickedFile!);
      if (attachmentUrl == null) {
        setState(() {
          _busy = false;
          _error = l10n.fileUploadFailed;
        });
        return;
      }
    }

    final id = await provider.createPlan(
      traineeId: widget.traineeId,
      name: _nameCtrl.text.trim(),
      weekStartDate: _weekStartString,
      targetCalories: int.tryParse(_caloriesCtrl.text) ?? 2000,
      targetProtein: int.tryParse(_proteinCtrl.text) ?? 150,
      targetCarbs: int.tryParse(_carbsCtrl.text) ?? 200,
      targetFat: int.tryParse(_fatCtrl.text) ?? 65,
      durationMonths: _durationMonths,
      attachmentUrl: attachmentUrl,
    );

    if (!mounted) return;
    setState(() => _busy = false);

    if (id == null) {
      setState(() => _error = provider.error ?? l10n.somethingWentWrong);
      return;
    }

    if (_mode == _PlanMode.build) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BuildMealPlanScreen(
            planId: id,
            traineeName: widget.traineeName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.planUploadedSuccess),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final t = _targets;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(
          l10n.newMealPlan(widget.traineeName),
          style: TextStyle(
              fontWeight: FontWeight.w700, color: colors.fg, fontSize: 16),
        ),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode toggle
            _ModeToggle(
              mode: _mode,
              onChanged: (m) => setState(() => _mode = m),
            ),
            const SizedBox(height: 20),

            // Plan name
            RoundTextField(
              textEditingController: _nameCtrl,
              hintText: l10n.planNameHint,
              icon: 'assets/icons/user_icon.png',
              textInputType: TextInputType.text,
            ),
            const SizedBox(height: 16),

            // Week start + duration
            Row(
              children: [
                Expanded(child: _dateField(colors, l10n)),
                const SizedBox(width: 12),
                _DurationStepper(
                  months: _durationMonths,
                  onChanged: (v) => setState(() => _durationMonths = v),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Calculator section ──────────────────────────────────────────
            _SectionTitle(l10n.traineeMeasurements, Icons.straighten),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _numField(colors, _heightCtrl, l10n.heightCmLabel,
                      Icons.height, () => setState(() {})),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _numField(colors, _weightCtrl, l10n.weightKgLabel,
                      Icons.monitor_weight_outlined, () => setState(() {})),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _numField(colors, _ageCtrl, l10n.ageLabel,
                      Icons.cake_outlined, () => setState(() {})),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SexToggle(
                sex: _sex,
                l10n: l10n,
                onChanged: (s) => setState(() => _sex = s)),
            const SizedBox(height: 14),
            _GoalPicker(
                goal: _goal,
                l10n: l10n,
                onChanged: (g) => setState(() => _goal = g)),
            const SizedBox(height: 14),
            _ActivityPicker(
                activity: _activity,
                l10n: l10n,
                onChanged: (a) => setState(() => _activity = a)),
            const SizedBox(height: 20),

            // ── Computed targets panel ──────────────────────────────────────
            if (t != null)
              _TargetsPanel(targets: t, l10n: l10n, onApply: _applyTargets)
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor1.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calculate_outlined,
                        color: AppColors.primaryColor1, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.enterMeasurementsHint,
                        style: TextStyle(fontSize: 12, color: colors.subFg),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // ── Mode-specific body ──────────────────────────────────────────
            if (_mode == _PlanMode.build) ...[
              _SectionTitle(l10n.dailyMacroTargets, Icons.tune),
              const SizedBox(height: 12),
              _MacroField(
                  ctrl: _caloriesCtrl,
                  label: l10n.caloriesKcal,
                  icon: Icons.local_fire_department_outlined,
                  iconColor: AppColors.primaryColor1),
              const SizedBox(height: 12),
              _MacroField(
                  ctrl: _proteinCtrl,
                  label: l10n.proteinG,
                  icon: Icons.set_meal_outlined,
                  iconColor: const Color(0xFFE53935)),
              const SizedBox(height: 12),
              _MacroField(
                  ctrl: _carbsCtrl,
                  label: l10n.carbsG,
                  icon: Icons.breakfast_dining_outlined,
                  iconColor: const Color(0xFF2196F3)),
              const SizedBox(height: 12),
              _MacroField(
                  ctrl: _fatCtrl,
                  label: l10n.fatG,
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFFFFC107)),
            ] else ...[
              _SectionTitle(l10n.planFilePdfImage, Icons.upload_file),
              const SizedBox(height: 12),
              _FilePickerTile(
                file: _pickedFile,
                l10n: l10n,
                onPick: _pickFile,
                onClear: () => setState(() => _pickedFile = null),
              ),
            ],
            const SizedBox(height: 24),

            if (_error != null) ...[
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.errorColor, fontSize: 13)),
              const SizedBox(height: 12),
            ],

            _busy
                ? const LiaqhPageLoader()
                : RoundGradientButton(
                    title: _mode == _PlanMode.build
                        ? l10n.createPlanAndBuild
                        : l10n.uploadAndAssignPlan,
                    onPressed: _submit,
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _dateField(AppThemeColors colors, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: colors.listTile,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppColors.primaryColor1, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${_weekStart.day.toString().padLeft(2, '0')}/'
                '${_weekStart.month.toString().padLeft(2, '0')}/'
                '${_weekStart.year}',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.fg,
                    fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField(AppThemeColors colors, TextEditingController ctrl,
      String label, IconData icon, VoidCallback onChanged) {
    return Container(
      decoration: BoxDecoration(
          color: colors.listTile, borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => onChanged(),
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: FontWeight.w700, color: colors.fg, fontSize: 15),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
          prefixIcon:
              Icon(icon, color: AppColors.primaryColor1, size: 18),
          labelText: label,
          labelStyle: TextStyle(fontSize: 11, color: colors.subFg),
          floatingLabelAlignment: FloatingLabelAlignment.center,
        ),
      ),
    );
  }
}

// ── Mode toggle ────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final _PlanMode mode;
  final ValueChanged<_PlanMode> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    Widget tab(_PlanMode m, IconData icon, String label) {
      final sel = mode == m;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(m),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: sel
                  ? LinearGradient(colors: AppColors.primaryG)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(icon,
                    size: 20, color: sel ? Colors.white : colors.subFg),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : colors.subFg)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: colors.listTile, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          tab(_PlanMode.build, Icons.construction_outlined, l10n.planBuildInApp),
          const SizedBox(width: 4),
          tab(_PlanMode.upload, Icons.upload_file_outlined, l10n.planUploadFile),
        ],
      ),
    );
  }
}

// ── Duration stepper ───────────────────────────────────────────────────────

class _DurationStepper extends StatelessWidget {
  final int months;
  final ValueChanged<int> onChanged;
  const _DurationStepper({required this.months, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
          color: colors.listTile, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepBtn(Icons.remove,
              months > 1 ? () => onChanged(months - 1) : null),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Text('$months',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: colors.fg)),
                Text(
                    months == 1
                        ? AppLocalizations.of(context).monthSingular
                        : AppLocalizations.of(context).monthPlural,
                    style: TextStyle(fontSize: 10, color: colors.subFg)),
              ],
            ),
          ),
          _stepBtn(Icons.add,
              months < 12 ? () => onChanged(months + 1) : null),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback? onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: onTap == null
                ? Colors.grey.withValues(alpha: 0.15)
                : AppColors.primaryColor1.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              size: 16,
              color: onTap == null
                  ? Colors.grey
                  : AppColors.primaryColor1),
        ),
      );
}

// ── Section title ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SectionTitle(this.text, this.icon);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor1),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14, color: colors.fg)),
      ],
    );
  }
}

// ── Sex toggle ─────────────────────────────────────────────────────────────

class _SexToggle extends StatelessWidget {
  final Sex sex;
  final AppLocalizations l10n;
  final ValueChanged<Sex> onChanged;
  const _SexToggle(
      {required this.sex, required this.l10n, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget chip(Sex s, String label, IconData icon) {
      final sel = sex == s;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(s),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: sel
                  ? AppColors.primaryColor1.withValues(alpha: 0.14)
                  : colors.listTile,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: sel
                      ? AppColors.primaryColor1
                      : Colors.transparent,
                  width: 1.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 16,
                    color: sel ? AppColors.primaryColor1 : colors.subFg),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color:
                            sel ? AppColors.primaryColor1 : colors.subFg)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(Sex.male, l10n.male, Icons.male),
        chip(Sex.female, l10n.female, Icons.female),
      ],
    );
  }
}

// ── Goal picker ────────────────────────────────────────────────────────────

class _GoalPicker extends StatelessWidget {
  final FitnessGoal goal;
  final AppLocalizations l10n;
  final ValueChanged<FitnessGoal> onChanged;
  const _GoalPicker(
      {required this.goal, required this.l10n, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FitnessGoal.values.map((g) {
        final sel = goal == g;
        return GestureDetector(
          onTap: () => onChanged(g),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              gradient:
                  sel ? LinearGradient(colors: AppColors.primaryG) : null,
              color: sel ? null : colors.listTile,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_goalLabel(l10n, g),
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: sel ? Colors.white : colors.subFg)),
          ),
        );
      }).toList(),
    );
  }
}

// ── Activity picker ────────────────────────────────────────────────────────

class _ActivityPicker extends StatelessWidget {
  final ActivityLevel activity;
  final AppLocalizations l10n;
  final ValueChanged<ActivityLevel> onChanged;
  const _ActivityPicker(
      {required this.activity, required this.l10n, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ActivityLevel.values.map((a) {
        final sel = activity == a;
        return GestureDetector(
          onTap: () => onChanged(a),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: sel
                  ? AppColors.primaryColor1.withValues(alpha: 0.10)
                  : colors.listTile,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                      sel ? AppColors.primaryColor1 : Colors.transparent,
                  width: 1.2),
            ),
            child: Row(
              children: [
                Icon(
                    sel
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18,
                    color: sel ? AppColors.primaryColor1 : colors.subFg),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_activityLabel(l10n, a),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: colors.fg)),
                      Text(_activityHint(l10n, a),
                          style: TextStyle(
                              fontSize: 11, color: colors.subFg)),
                    ],
                  ),
                ),
                Text('×${a.factor}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.subFg)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Targets panel ──────────────────────────────────────────────────────────

class _TargetsPanel extends StatelessWidget {
  final NutritionTargets targets;
  final AppLocalizations l10n;
  final VoidCallback onApply;
  const _TargetsPanel(
      {required this.targets, required this.l10n, required this.onApply});

  @override
  Widget build(BuildContext context) {
    final t = targets;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.recommendedDailyTargets,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Big calories ring + macros
          Row(
            children: [
              _bigStat('${t.calories}', 'kcal / day',
                  Icons.local_fire_department),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    _macroBar(l10n.protein, t.proteinGrams, t.proteinPct,
                        const Color(0xFFFF8A80)),
                    const SizedBox(height: 8),
                    _macroBar(l10n.carbs, t.carbsGrams, t.carbsPct,
                        const Color(0xFF82B1FF)),
                    const SizedBox(height: 8),
                    _macroBar(l10n.fat, t.fatGrams, t.fatPct,
                        const Color(0xFFFFE082)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pill(Icons.water_drop, '${t.waterLiters} L', l10n.water),
              _pill(Icons.bolt, '${t.bmr.round()}', l10n.bmrLabel),
              _pill(Icons.directions_run, '${t.tdee.round()}', l10n.tdeeLabel),
              _pill(Icons.monitor_weight, '${t.bmi}', t.bmiCategory),
              _pill(Icons.restaurant, '${t.proteinPerMeal}g', l10n.proteinPerMeal),
              _pill(Icons.grass, '${t.fiberGrams}g', l10n.fiber),
              _pill(
                  Icons.trending_up,
                  '${t.weeklyRateKg > 0 ? '+' : ''}${t.weeklyRateKg} kg',
                  l10n.perWeek),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.check, size: 16),
              label: Text(l10n.useTheseTargets),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1B5E20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(0, 44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigStat(String value, String label, IconData icon) => Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22)),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      );

  Widget _macroBar(String label, int grams, int pct, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11)),
              const Spacer(),
              Text('${grams}g · $pct%',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      );

  Widget _pill(IconData icon, String value, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 9)),
              ],
            ),
          ],
        ),
      );
}

// ── File picker tile ───────────────────────────────────────────────────────

class _FilePickerTile extends StatelessWidget {
  final File? file;
  final AppLocalizations l10n;
  final VoidCallback onPick;
  final VoidCallback onClear;
  const _FilePickerTile(
      {required this.file,
      required this.l10n,
      required this.onPick,
      required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (file == null) {
      return GestureDetector(
        onTap: onPick,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: BoxDecoration(
            color: AppColors.primaryColor1.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primaryColor1.withValues(alpha: 0.4),
                width: 1.5,
                style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              const Icon(Icons.cloud_upload_outlined,
                  size: 40, color: AppColors.primaryColor1),
              const SizedBox(height: 10),
              Text(l10n.tapToChooseFile,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: colors.fg)),
              const SizedBox(height: 4),
              Text(l10n.fileTypesHint,
                  style: TextStyle(fontSize: 11, color: colors.subFg)),
            ],
          ),
        ),
      );
    }
    final name = file!.path.split(RegExp(r'[\\/]')).last;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: colors.listTile, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file,
              color: AppColors.primaryColor1, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: colors.fg)),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.errorColor,
          ),
        ],
      ),
    );
  }
}

// ── Macro field helper ─────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: colors.listTile, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Always-visible label so the coach knows what each value means.
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.fg)),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: TextField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.fg),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                isDense: true,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(fontSize: 14, color: colors.subFg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
