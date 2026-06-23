import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/data/models/trainee_report_models.dart';
import 'package:fitnessapp/data/repositories/report_repository.dart';
import 'package:fitnessapp/data/services/api_service.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';

class TraineeReportScreen extends StatefulWidget {
  static const routeName = '/TraineeReportScreen';

  final String traineeId;
  final String traineeName;

  const TraineeReportScreen({
    super.key,
    required this.traineeId,
    required this.traineeName,
  });

  @override
  State<TraineeReportScreen> createState() => _TraineeReportScreenState();
}

class _TraineeReportScreenState extends State<TraineeReportScreen> {
  final ReportRepository _repo = ReportRepository(ApiService());

  final CoachAssessment _assessment = CoachAssessment();
  final Map<String, TextEditingController> _controllers = {};

  late DateTime _from;
  late DateTime _to;

  TraineeReport? _report;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Default to all-time so the report covers every record the trainee has.
    _from = DateTime(2020, 1, 1);
    _to = now;
    _loadData();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrl(String key, String initial, void Function(String) onChanged) {
    final existing = _controllers[key];
    if (existing != null) return existing;
    final c = TextEditingController(text: initial);
    c.addListener(() => onChanged(c.text));
    _controllers[key] = c;
    return c;
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final report = await _repo.getTraineeReport(widget.traineeId, _from, _to);
      if (!mounted) return;
      setState(() {
        _report = report;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load report: $e')),
      );
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _from : _to;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
  }

  // ───────────────────────────────────────── UI ─────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.fg,
        title: const Text('Trainee Report'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: LiaqhPageLoader())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPeriodSelector(colors),
                  const SizedBox(height: 16),
                  if (_report == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'No data loaded. Adjust the period and tap "Load data".',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.subFg),
                      ),
                    )
                  else ...[
                    _buildAssessmentForm(colors),
                    const SizedBox(height: 24),
                    _buildGenerateButton(),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector(AppThemeColors colors) {
    final df = DateFormat.yMMMd();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Report Period',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: colors.fg, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _datePill(
                    colors,
                    'From',
                    _from.year <= 2020 ? 'All time' : df.format(_from),
                    () => _pickDate(isFrom: true)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _datePill(colors, 'To', df.format(_to),
                    () => _pickDate(isFrom: false)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor1,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Load data'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePill(
      AppThemeColors colors, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.inputFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: colors.subFg)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.primaryColor1),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(value,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: colors.fg),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentForm(AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(colors, 'Coach Assessment'),
        const SizedBox(height: 12),
        _field(colors, 'summary', 'Overall progress summary',
            _assessment.summary, (v) => _assessment.summary = v, lines: 3),
        _field(colors, 'wentWell', 'What went well', _assessment.whatWentWell,
            (v) => _assessment.whatWentWell = v, lines: 3),
        _field(colors, 'improve', 'Areas to improve',
            _assessment.needsImprovement, (v) => _assessment.needsImprovement = v,
            lines: 3),
        _field(colors, 'behavior', 'Behavior / commitment notes',
            _assessment.behaviorNotes, (v) => _assessment.behaviorNotes = v,
            lines: 3),
        _field(colors, 'recWorkout', 'Recommended workout changes',
            _assessment.recommendedWorkout,
            (v) => _assessment.recommendedWorkout = v, lines: 3),
        _field(colors, 'recNutrition', 'Recommended nutrition changes',
            _assessment.recommendedNutrition,
            (v) => _assessment.recommendedNutrition = v, lines: 3),
        _field(colors, 'weightTarget', 'Weight target',
            _assessment.weightTarget, (v) => _assessment.weightTarget = v),
        const SizedBox(height: 20),
        _sectionTitle(colors, 'Next Period Plan'),
        const SizedBox(height: 12),
        _field(colors, 'updatedGoal', 'Updated goal', _assessment.updatedGoal,
            (v) => _assessment.updatedGoal = v),
        _field(colors, 'newTargetWeight', 'New target weight',
            _assessment.newTargetWeight, (v) => _assessment.newTargetWeight = v),
        _field(colors, 'programChanges', 'Recommended program changes',
            _assessment.programChanges, (v) => _assessment.programChanges = v,
            lines: 3),
        _field(colors, 'nutritionAdj', 'Nutrition adjustments',
            _assessment.nutritionAdjustments,
            (v) => _assessment.nutritionAdjustments = v, lines: 3),
        _field(colors, 'nextInBody', 'Next InBody date',
            _assessment.nextInBodyDate, (v) => _assessment.nextInBodyDate = v),
        _field(colors, 'nextReport', 'Next report date',
            _assessment.nextReportDate, (v) => _assessment.nextReportDate = v),
      ],
    );
  }

  Widget _sectionTitle(AppThemeColors colors, String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primaryColor1,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: colors.fg)),
      ],
    );
  }

  Widget _field(AppThemeColors colors, String key, String label, String initial,
      void Function(String) onChanged,
      {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _ctrl(key, initial, onChanged),
        maxLines: lines,
        style: TextStyle(color: colors.fg),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colors.subFg),
          filled: true,
          fillColor: colors.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryColor1, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    final enabled = _report != null;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? _generatePdf : null,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Generate PDF'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor1,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ──────────────────────────────────────── PDF ─────────────────────────────

  Future<void> _generatePdf() async {
    final report = _report;
    if (report == null) return;
    try {
      final doc = _buildDocument(report, _assessment);
      await Printing.layoutPdf(onLayout: (format) => doc.save());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
    }
  }

  static const PdfColor _pdfAccent = PdfColor.fromInt(0xFFD97757);
  static const PdfColor _pdfLight = PdfColor.fromInt(0xFFF4E6E0);
  static const PdfColor _pdfMuted = PdfColor.fromInt(0xFF666666);
  static const PdfColor _pdfDark = PdfColor.fromInt(0xFF222222);

  pw.Document _buildDocument(TraineeReport r, CoachAssessment a) {
    final doc = pw.Document();
    final df = DateFormat.yMMMd();

    doc.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.fromLTRB(36, 36, 36, 48),
        ),
        header: (ctx) => ctx.pageNumber == 1
            ? _pdfHeader(r, df)
            : pw.SizedBox(),
        footer: (ctx) => _pdfFooter(ctx, r.coachName),
        build: (ctx) => [
          _section1(r, df),
          _section2(r),
          _section3(r, a),
          _section4(r, a),
          _section5(r),
          _section6(r),
          _section7(a),
          _section8(a),
        ],
      ),
    );
    return doc;
  }

  pw.Widget _pdfHeader(TraineeReport r, DateFormat df) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 18),
      padding: const pw.EdgeInsets.all(18),
      decoration: const pw.BoxDecoration(color: _pdfAccent),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('TRAINEE PROGRESS REPORT',
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1)),
          pw.SizedBox(height: 6),
          pw.Text(r.fullName.isNotEmpty ? r.fullName : widget.traineeName,
              style: const pw.TextStyle(color: PdfColors.white, fontSize: 14)),
          pw.SizedBox(height: 2),
          pw.Text(
              'Period: ${df.format(r.periodStart)}  —  ${df.format(r.periodEnd)}',
              style: const pw.TextStyle(
                  color: PdfColors.white, fontSize: 11)),
        ],
      ),
    );
  }

  pw.Widget _pdfFooter(pw.Context ctx, String coachName) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _pdfLight, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Generated by $coachName · Liaqh',
              style: const pw.TextStyle(fontSize: 9, color: _pdfMuted)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: _pdfMuted)),
        ],
      ),
    );
  }

  // ── reusable helpers ──

  pw.Widget _sectionHeader(int number, String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16, bottom: 8),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const pw.BoxDecoration(color: _pdfLight),
      child: pw.Row(
        children: [
          pw.Container(
            width: 22,
            height: 22,
            alignment: pw.Alignment.center,
            decoration: const pw.BoxDecoration(
                color: _pdfAccent, shape: pw.BoxShape.circle),
            child: pw.Text('$number',
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(width: 8),
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: _pdfDark)),
        ],
      ),
    );
  }

  pw.Widget _kvRow(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 160,
            child: pw.Text(key,
                style: pw.TextStyle(
                    fontSize: 10,
                    color: _pdfMuted,
                    fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(
            child: pw.Text(value,
                style: const pw.TextStyle(fontSize: 10, color: _pdfDark)),
          ),
        ],
      ),
    );
  }

  pw.Widget _paragraph(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 10,
                  color: _pdfAccent,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(value,
              style: const pw.TextStyle(fontSize: 10, color: _pdfDark)),
        ],
      ),
    );
  }

  pw.Widget _table(List<String> headers, List<List<String>> rows) {
    pw.Widget cell(String t, {bool header = false}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: pw.Text(t,
              style: pw.TextStyle(
                  fontSize: 9,
                  color: header ? PdfColors.white : _pdfDark,
                  fontWeight:
                      header ? pw.FontWeight.bold : pw.FontWeight.normal)),
        );
    return pw.Table(
      border: pw.TableBorder.all(color: _pdfLight, width: 0.5),
      columnWidths: {
        for (var i = 0; i < headers.length; i++)
          i: i == 0 ? const pw.FlexColumnWidth(2) : const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _pdfAccent),
          children: headers.map((h) => cell(h, header: true)).toList(),
        ),
        ...rows.map((row) => pw.TableRow(
              children: row.map((c) => cell(c)).toList(),
            )),
      ],
    );
  }

  // ── formatting helpers ──

  String _num(num? v, {String suffix = ''}) =>
      v == null ? '—' : '${_trim(v)}$suffix';

  String _trim(num v) {
    if (v is int) return v.toString();
    final d = v.toDouble();
    return d == d.roundToDouble() ? d.toInt().toString() : d.toStringAsFixed(1);
  }

  String _change(double? v) {
    if (v == null) return '—';
    final sign = v > 0 ? '+' : '';
    return '$sign${_trim(v)}';
  }

  String _statusLabel(String raw) {
    switch (raw) {
      case 'OnTrack':
        return 'On Track';
      case 'AtRisk':
        return 'Needs Attention';
      case 'OffTrack':
        return 'Off Track';
      default:
        return raw.isEmpty ? '—' : raw;
    }
  }

  // ── Section builders ──

  pw.Widget _section1(TraineeReport r, DateFormat df) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader(1, 'TRAINEE INFORMATION'),
        _kvRow('Full name', r.fullName.isNotEmpty ? r.fullName : widget.traineeName),
        _kvRow('Age', _num(r.age)),
        _kvRow('Height', _num(r.heightCm, suffix: ' cm')),
        _kvRow('Current weight', _num(r.currentWeightKg, suffix: ' kg')),
        _kvRow('Goal', r.goal.isNotEmpty ? r.goal : '—'),
        _kvRow('Membership status',
            r.membershipStatus.isNotEmpty ? r.membershipStatus : '—'),
        _kvRow('Report period',
            '${df.format(r.periodStart)} - ${df.format(r.periodEnd)}'),
        _kvRow('Coach', r.coachName.isNotEmpty ? r.coachName : '—'),
      ],
    );
  }

  pw.Widget _section2(TraineeReport r) {
    final children = <pw.Widget>[_sectionHeader(2, 'BODY COMPOSITION (InBody)')];
    if (!r.hasInBody) {
      children.add(pw.Text('No InBody measurements recorded.',
          style: const pw.TextStyle(fontSize: 10, color: _pdfMuted)));
    } else {
      children.add(_table(
        ['Metric', 'Latest', 'Previous', 'Change'],
        [
          [
            'Weight (kg)',
            _num(r.latestWeight),
            _num(r.prevWeight),
            _change(r.weightChange)
          ],
          [
            'Muscle mass (kg)',
            _num(r.latestMuscle),
            _num(r.prevMuscle),
            _change(r.muscleChange)
          ],
          [
            'Body fat (%)',
            _num(r.latestBodyFat),
            _num(r.prevBodyFat),
            _change(r.bodyFatChange)
          ],
        ],
      ));
      children.add(pw.SizedBox(height: 8));
      children.add(_kvRow('Body water (%)', _num(r.bodyWater)));
      children.add(_kvRow('Visceral fat', _num(r.visceralFat)));
      children.add(_kvRow('BMI', _num(r.bmi)));
      children.add(_kvRow('Body Score',
          '${_num(r.bodyScore)} (${r.bodyScoreTrend})'));
      children.add(
          _kvRow('Overall assessment', _statusLabel(r.adherenceStatus)));
    }
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
  }

  pw.Widget _section3(TraineeReport r, CoachAssessment a) {
    final df = DateFormat.MMMd();
    final children = <pw.Widget>[
      _sectionHeader(3, 'WORKOUT PERFORMANCE'),
      _kvRow('Workouts planned', _num(r.workoutsPlanned)),
      _kvRow('Workouts completed', _num(r.workoutsCompleted)),
      _kvRow('Completion rate', _num(r.workoutCompletionRate, suffix: '%')),
    ];

    if (r.workoutDays.isNotEmpty) {
      children.add(pw.SizedBox(height: 6));
      children.add(_table(
        ['Date', 'Status'],
        r.workoutDays
            .map((d) =>
                [df.format(d.date), d.completed ? 'Completed' : 'Missed'])
            .toList(),
      ));
    }

    final best = r.bestExercise;
    if (best != null && best.isNotEmpty) {
      final gain = r.bestExerciseGainKg;
      children.add(pw.SizedBox(height: 6));
      children.add(_kvRow(
          'Best exercise',
          gain != null ? '$best (+${_trim(gain)} kg)' : best));
    }

    if (r.progressiveOverload.isNotEmpty) {
      children.add(pw.SizedBox(height: 6));
      children.add(_table(
        ['Exercise', 'From (kg)', 'To (kg)'],
        r.progressiveOverload
            .map((p) => [p.exercise, _trim(p.fromKg), _trim(p.toKg)])
            .toList(),
      ));
    }

    if (a.recommendedWorkout.trim().isNotEmpty) {
      children.add(pw.SizedBox(height: 8));
      children.add(_paragraph('Coach notes', a.recommendedWorkout));
    }

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
  }

  pw.Widget _section4(TraineeReport r, CoachAssessment a) {
    final children = <pw.Widget>[
      _sectionHeader(4, 'NUTRITION ADHERENCE'),
      _kvRow('Meal days planned', _num(r.mealDaysPlanned)),
      _kvRow('Meal days logged', _num(r.mealDaysLogged)),
      _kvRow('Completion rate', _num(r.mealCompletionRate, suffix: '%')),
      pw.SizedBox(height: 6),
      _table(
        ['Macro', 'Avg / day', 'Target'],
        [
          ['Calories', _num(r.avgCalories), _num(r.targetCalories)],
          ['Protein (g)', _num(r.avgProtein), _num(r.targetProtein)],
          ['Carbs (g)', _num(r.avgCarbs), _num(r.targetCarbs)],
          ['Fat (g)', _num(r.avgFat), _num(r.targetFat)],
        ],
      ),
    ];

    if (r.rejectedMeals.isNotEmpty) {
      children.add(pw.SizedBox(height: 6));
      children.add(_table(
        ['Rejected meal', 'Reason'],
        r.rejectedMeals
            .map((m) => [m.mealType, m.reason ?? '—'])
            .toList(),
      ));
    }

    if (a.recommendedNutrition.trim().isNotEmpty) {
      children.add(pw.SizedBox(height: 8));
      children.add(_paragraph('Coach notes', a.recommendedNutrition));
    }

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
  }

  pw.Widget _section5(TraineeReport r) {
    String gap(int target, int actual) {
      final g = target - actual;
      final sign = g > 0 ? '+' : '';
      return '$sign$g';
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader(5, 'MACRO TARGETS VS ACTUAL'),
        _table(
          ['Macro', 'Target', 'Actual (avg)', 'Gap'],
          [
            [
              'Protein (g)',
              _num(r.targetProtein),
              _num(r.avgProtein),
              gap(r.targetProtein, r.avgProtein)
            ],
            [
              'Calories',
              _num(r.targetCalories),
              _num(r.avgCalories),
              gap(r.targetCalories, r.avgCalories)
            ],
            [
              'Carbs (g)',
              _num(r.targetCarbs),
              _num(r.avgCarbs),
              gap(r.targetCarbs, r.avgCarbs)
            ],
            [
              'Fat (g)',
              _num(r.targetFat),
              _num(r.avgFat),
              gap(r.targetFat, r.avgFat)
            ],
          ],
        ),
      ],
    );
  }

  pw.Widget _section6(TraineeReport r) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader(6, 'ADHERENCE & ENGAGEMENT'),
        _kvRow('Overall adherence score', _num(r.adherenceScore, suffix: '%')),
        _kvRow('Status', _statusLabel(r.adherenceStatus)),
        _kvRow('Current streak', _num(r.currentStreak, suffix: ' days')),
        _kvRow(
            'Badges earned',
            r.badgesThisPeriod.isNotEmpty
                ? r.badgesThisPeriod.join(', ')
                : 'None'),
        _kvRow('Points this period', _num(r.pointsThisPeriod)),
        _kvRow('Leaderboard rank',
            r.leaderboardRank != null ? '#${r.leaderboardRank}' : '—'),
      ],
    );
  }

  pw.Widget _section7(CoachAssessment a) {
    final items = <pw.Widget>[_sectionHeader(7, 'COACH ASSESSMENT')];
    void add(String label, String value) {
      if (value.trim().isEmpty) return;
      items.add(_paragraph(label, value));
    }

    add('Summary', a.summary);
    add('What went well', a.whatWentWell);
    add('Areas to improve', a.needsImprovement);
    add('Behavior notes', a.behaviorNotes);
    add('Recommended workout', a.recommendedWorkout);
    add('Recommended nutrition', a.recommendedNutrition);
    add('Weight target', a.weightTarget);

    if (items.length == 1) {
      items.add(pw.Text('No assessment provided.',
          style: const pw.TextStyle(fontSize: 10, color: _pdfMuted)));
    }
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start, children: items);
  }

  pw.Widget _section8(CoachAssessment a) {
    final items = <pw.Widget>[_sectionHeader(8, 'NEXT PERIOD PLAN')];
    void add(String label, String value) {
      if (value.trim().isEmpty) return;
      items.add(_paragraph(label, value));
    }

    add('Updated goal', a.updatedGoal);
    add('New target weight', a.newTargetWeight);
    add('Program changes', a.programChanges);
    add('Nutrition adjustments', a.nutritionAdjustments);
    add('Next InBody date', a.nextInBodyDate);
    add('Next report date', a.nextReportDate);

    if (items.length == 1) {
      items.add(pw.Text('No plan provided.',
          style: const pw.TextStyle(fontSize: 10, color: _pdfMuted)));
    }
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start, children: items);
  }
}
