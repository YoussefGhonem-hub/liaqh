import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/gym_admin_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Gym Admin creates a trainee and assigns them to a specific coach.
class AddTraineeAdminScreen extends StatefulWidget {
  final String coachUserId;
  final String coachName;
  const AddTraineeAdminScreen({
    Key? key,
    required this.coachUserId,
    required this.coachName,
  }) : super(key: key);

  @override
  State<AddTraineeAdminScreen> createState() => _AddTraineeAdminScreenState();
}

class _AddTraineeAdminScreenState extends State<AddTraineeAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  String _goal = 'Cut';

  static const _goals = ['Cut', 'Bulk', 'Maintain', 'Recomp'];

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<GymAdminProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    final ok = await provider.createTrainee(
      coachUserId: widget.coachUserId,
      email: _email.text.trim(),
      password: _password.text,
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
      goal: _goal,
      heightCm: double.parse(_height.text.trim()),
      currentWeightKg: double.parse(_weight.text.trim()),
      phoneNumber: _phone.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      messenger.showSnackBar(SnackBar(
          content: Text(l10n.traineeCreatedAndAssigned),
          backgroundColor: AppColors.successColor));
      nav.pop(true);
    } else {
      messenger.showSnackBar(SnackBar(
          content: Text(provider.error ?? l10n.failedToCreateTrainee),
          backgroundColor: AppColors.errorColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final busy = context.watch<GymAdminProvider>().busy;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        title: Text(l10n.newTrainee,
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor1.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.sports_rounded,
                    color: AppColors.primaryColor1, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.assignedToCoach(widget.coachName),
                      style: TextStyle(
                          color: colors.fg, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: _field(colors, _first, l10n.firstNameField,
                      required: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: _field(colors, _last, l10n.lastNameField,
                      required: true)),
            ]),
            const SizedBox(height: 12),
            _field(colors, _email, l10n.email,
                keyboardType: TextInputType.emailAddress, required: true),
            const SizedBox(height: 12),
            _field(colors, _password, l10n.tempPasswordField, required: true),
            const SizedBox(height: 12),
            _field(colors, _phone, l10n.phoneRequiredField,
                keyboardType: TextInputType.phone, required: true),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _field(colors, _height, l10n.heightCmField,
                      keyboardType: TextInputType.number, isNumber: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: _field(colors, _weight, l10n.weightKgField,
                      keyboardType: TextInputType.number, isNumber: true)),
            ]),
            const SizedBox(height: 16),
            Text(l10n.goal,
                style: TextStyle(
                    color: colors.subFg, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _goals.map((g) {
                final sel = _goal == g;
                return ChoiceChip(
                  label: Text(_goalLabel(l10n, g)),
                  selected: sel,
                  selectedColor: AppColors.primaryColor1,
                  backgroundColor: colors.card,
                  labelStyle: TextStyle(
                      color: sel ? Colors.white : colors.fg,
                      fontWeight: FontWeight.w600),
                  onSelected: (_) => setState(() => _goal = g),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: busy ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor1,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(l10n.createTrainee,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _goalLabel(AppLocalizations l10n, String goal) {
    switch (goal) {
      case 'Cut':
        return l10n.cut;
      case 'Bulk':
        return l10n.bulk;
      case 'Maintain':
        return l10n.maintain;
      case 'Recomp':
        return l10n.recomp;
      default:
        return goal;
    }
  }

  Widget _field(AppThemeColors colors, TextEditingController c, String label,
      {bool required = false,
      bool isNumber = false,
      TextInputType? keyboardType}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      style: TextStyle(color: colors.fg),
      validator: (v) {
        final l10n = AppLocalizations.of(context);
        if (required || isNumber) {
          if (v == null || v.trim().isEmpty) return l10n.required;
        }
        if (isNumber && double.tryParse(v!.trim()) == null) return l10n.invalid;
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.subFg),
        filled: true,
        fillColor: colors.card,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }
}
