import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const routeName = '/ChangePasswordScreen';
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _newPass = TextEditingController();
  final _confirm = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _submitting = false;

  @override
  void dispose() {
    _current.dispose();
    _newPass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final auth = context.read<AuthProvider>();
    final ok = await auth.changePassword(
      currentPassword: _current.text,
      newPassword: _newPass.text,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully.'),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Could not change password.'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
        title: Text('Change Password',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 18, color: colors.fg)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryG,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.lock_outline_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Use at least 8 characters. Choose a strong password you don\'t use elsewhere.',
                      style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _PasswordField(
              controller: _current,
              label: 'Current Password',
              obscure: !_showCurrent,
              onToggle: () => setState(() => _showCurrent = !_showCurrent),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter your current password' : null,
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: _newPass,
              label: 'New Password',
              obscure: !_showNew,
              onToggle: () => setState(() => _showNew = !_showNew),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter a new password';
                if (v.length < 8) return 'Must be at least 8 characters';
                if (v == _current.text) {
                  return 'New password must differ from the current one';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: _confirm,
              label: 'Confirm New Password',
              obscure: !_showConfirm,
              onToggle: () => setState(() => _showConfirm = !_showConfirm),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Re-enter the new password';
                if (v != _newPass.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 28),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor1,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Update Password',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(color: colors.fg),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.subFg),
        filled: true,
        fillColor: colors.inputFill,
        prefixIcon: Icon(Icons.lock_outline, color: colors.subFg, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: colors.subFg,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryColor1, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
        ),
      ),
    );
  }
}
