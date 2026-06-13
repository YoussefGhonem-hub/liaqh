import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/gym_admin_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Gym Admin creates a coach account.
class AddCoachScreen extends StatefulWidget {
  const AddCoachScreen({Key? key}) : super(key: key);

  @override
  State<AddCoachScreen> createState() => _AddCoachScreenState();
}

class _AddCoachScreenState extends State<AddCoachScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<GymAdminProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    final ok = await provider.createCoach(
      email: _email.text.trim(),
      password: _password.text,
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
      phoneNumber: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      messenger.showSnackBar(SnackBar(
          content: Text(l10n.coachCreated),
          backgroundColor: AppColors.successColor));
      nav.pop(true);
    } else {
      messenger.showSnackBar(SnackBar(
          content: Text(provider.error ?? l10n.failedToCreateCoach),
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
        title: Text(l10n.newCoach,
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
            _field(colors, _phone, l10n.phoneOptionalField,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _field(colors, _bio, l10n.bioOptionalField, maxLines: 3),
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
                    : Text(l10n.createCoach,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(AppThemeColors colors, TextEditingController c, String label,
      {bool required = false, TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: colors.fg),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty)
              ? AppLocalizations.of(context).required
              : null
          : null,
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
