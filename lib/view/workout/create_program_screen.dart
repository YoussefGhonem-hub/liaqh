import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/providers/workout_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import 'build_workout_day_screen.dart';

class CreateProgramScreen extends StatefulWidget {
  final String traineeId;
  final String traineeName;

  const CreateProgramScreen({
    Key? key,
    required this.traineeId,
    required this.traineeName,
  }) : super(key: key);

  @override
  State<CreateProgramScreen> createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends State<CreateProgramScreen> {
  final _nameCtrl  = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _periodType = 'Week';
  DateTime _startDate = DateTime.now();
  String? _error;

  static const _periods = ['Week', 'Month', 'Quarter'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate,
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
    if (d != null) setState(() => _startDate = d);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = l10n.programNameRequired);
      return;
    }
    setState(() => _error = null);
    final provider = context.read<WorkoutProvider>();
    final id = await provider.createProgram(
      traineeId: widget.traineeId,
      name: _nameCtrl.text.trim(),
      periodType: _periodType,
      startDate: _startDate,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );
    if (id != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BuildWorkoutDayScreen(
            programId: id,
            programName: _nameCtrl.text.trim(),
            traineeId: widget.traineeId,
            traineeName: widget.traineeName,
          ),
        ),
      );
    }
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
          l10n.newProgram(widget.traineeName),
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
            RoundTextField(
              textEditingController: _nameCtrl,
              hintText: l10n.programNameHint,
              icon: 'assets/icons/user_icon.png',
              textInputType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            Text(l10n.duration,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: colors.fg)),
            const SizedBox(height: 8),
            Row(
              children: _periods.map((p) {
                final selected = _periodType == p;
                final label = p == 'Week' ? l10n.week : p == 'Month' ? l10n.month : l10n.quarter;
                final days = p == 'Week' ? '7 days' : p == 'Month' ? '30 days' : '90 days';
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _periodType = p),
                    child: Container(
                      margin: EdgeInsets.only(
                          right: p != _periods.last ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryColor1
                            : colors.listTile,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(label,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? Colors.white
                                      : colors.fg,
                                  fontSize: 14)),
                          Text(
                            days,
                            style: TextStyle(
                                fontSize: 11,
                                color: selected
                                    ? Colors.white70
                                    : colors.subFg),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(l10n.startDate,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: colors.fg)),
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
                      '${_startDate.day.toString().padLeft(2, '0')}/'
                      '${_startDate.month.toString().padLeft(2, '0')}/'
                      '${_startDate.year}',
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
            const SizedBox(height: 28),
            provider.loading
                ? const LiaqhPageLoader()
                : RoundGradientButton(
                    title: l10n.createAndAddDays,
                    onPressed: _submit,
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
