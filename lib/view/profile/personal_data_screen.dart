import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalDataScreen extends StatefulWidget {
  static const routeName = '/PersonalDataScreen';
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _firstNameCtrl = TextEditingController(text: user?.firstName ?? '');
    _lastNameCtrl  = TextEditingController(text: user?.lastName  ?? '');
    _phoneCtrl     = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(
      firstName: _firstNameCtrl.text.trim(),
      lastName:  _lastNameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).profileUpdated)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? AppLocalizations.of(context).errorGeneric),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().currentUser;
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.personalDataTitle,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        actions: [
          if (!_editing)
            TextButton(
              onPressed: () => setState(() => _editing = true),
              child: Text(l10n.edit,
                  style: const TextStyle(color: AppColors.primaryColor1, fontWeight: FontWeight.w600)),
            )
          else
            TextButton(
              onPressed: loading ? null : _save,
              child: loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.save,
                      style: const TextStyle(color: AppColors.primaryColor1, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: user == null
          ? const LiaqhPageLoader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primaryColor1.withValues(alpha: 0.15),
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(user.fullName,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colors.fg)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor1.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(user.role,
                          style: const TextStyle(
                              color: AppColors.primaryColor1,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                    const SizedBox(height: 28),

                    // Info card
                    Container(
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: colors.shadow, blurRadius: 6, offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        children: [
                          _editing
                              ? _EditField(
                                  icon: Icons.person_outline,
                                  label: l10n.firstName,
                                  controller: _firstNameCtrl,
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? l10n.firstName
                                      : null,
                                )
                              : _InfoRow(
                                  icon: Icons.person_outline,
                                  label: l10n.firstName,
                                  value: user.firstName),
                          const _RowDivider(),
                          _editing
                              ? _EditField(
                                  icon: Icons.person_outline,
                                  label: l10n.lastName,
                                  controller: _lastNameCtrl,
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? l10n.lastName
                                      : null,
                                )
                              : _InfoRow(
                                  icon: Icons.person_outline,
                                  label: l10n.lastName,
                                  value: user.lastName),
                          const _RowDivider(),
                          if (_editing)
                            _EditField(
                              icon: Icons.phone_outlined,
                              label: l10n.phoneLabel,
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                            ),
                          const _RowDivider(),
                          _InfoRow(
                              icon: Icons.email_outlined,
                              label: l10n.emailLabel,
                              value: user.email),
                          const _RowDivider(),
                          _InfoRow(
                              icon: Icons.shield_outlined,
                              label: l10n.role,
                              value: user.role),
                          const _RowDivider(),
                          _InfoRow(
                            icon: Icons.business_outlined,
                            label: l10n.gymIdLabel,
                            value: user.gymId.isNotEmpty ? user.gymId : '—',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor1, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: TextStyle(color: colors.subFg, fontSize: 13)),
          ),
          Text(value,
              style: TextStyle(
                  color: colors.fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  const _EditField({
    required this.icon,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
  });
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor1, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: keyboardType,
              style: TextStyle(
                  color: colors.fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: colors.subFg, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Divider(height: 1, indent: 50, endIndent: 16, color: colors.divider);
  }
}
