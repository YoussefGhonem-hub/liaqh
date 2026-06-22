import 'package:fitnessapp/data/models/trainee_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/trainee_provider.dart';
import 'package:fitnessapp/utils/app_alerts.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/utils/nutrition_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class AddTraineeScreen extends StatefulWidget {
  static String routeName = "/AddTraineeScreen";
  const AddTraineeScreen({Key? key}) : super(key: key);

  @override
  State<AddTraineeScreen> createState() => _AddTraineeScreenState();
}

class _AddTraineeScreenState extends State<AddTraineeScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _selectedGoal = 'Maintain';
  bool _obscure = true;

  final _goals = ['Cut', 'Bulk', 'Maintain', 'Recomp'];

  @override
  void dispose() {
    for (final c in [_emailCtrl, _passwordCtrl, _firstNameCtrl, _lastNameCtrl, _phoneCtrl, _heightCtrl, _weightCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  static const _appStoreLink =
      'https://apps.apple.com/eg/app/%D9%84%D9%8A%D8%A7%D9%82%D8%A9-liaqh/id6782129246';

  /// Opens the system contact picker (no runtime permission needed) and fills
  /// the phone field. If the contact has several numbers, asks which to use.
  Future<void> _pickFromContacts() async {
    final l10n = AppLocalizations.of(context);
    try {
      final contact = await FlutterContacts.openExternalPick();
      if (contact == null || !mounted) return;

      final phones = contact.phones;
      if (phones.isEmpty) {
        AppAlerts.error(context, l10n.noPhoneInContact);
        return;
      }

      String number = phones.first.number;
      if (phones.length > 1) {
        final picked = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: context.colors.card,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.chooseNumber,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.colors.fg)),
                ),
                ...phones.map((p) => ListTile(
                      leading: Icon(Icons.phone, color: context.colors.subFg),
                      title: Text(p.number,
                          style: TextStyle(color: context.colors.fg)),
                      onTap: () => Navigator.pop(ctx, p.number),
                    )),
              ],
            ),
          ),
        );
        if (picked == null) return;
        number = picked;
      }

      setState(() {
        _phoneCtrl.text = number.replaceAll(RegExp(r'\s'), '');
        // Prefill the name from the contact if those fields are still empty.
        if (_firstNameCtrl.text.trim().isEmpty &&
            contact.name.first.isNotEmpty) {
          _firstNameCtrl.text = contact.name.first;
        }
        if (_lastNameCtrl.text.trim().isEmpty &&
            contact.name.last.isNotEmpty) {
          _lastNameCtrl.text = contact.name.last;
        }
      });
    } catch (e) {
      if (mounted) AppAlerts.handleError(context, e);
    }
  }

  /// Normalizes a raw phone into the international digits WhatsApp expects.
  /// Local Egyptian numbers (leading 0) are prefixed with the 20 country code.
  String _whatsappNumber(String raw) {
    var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.startsWith('00')) d = d.substring(2);
    if (d.startsWith('0')) d = '20${d.substring(1)}';
    return d;
  }

  Future<void> _sendWhatsAppWelcome() async {
    final l10n = AppLocalizations.of(context);
    final name = _firstNameCtrl.text.trim();
    final message = l10n.whatsappWelcomeTemplate(
      name,
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      _appStoreLink,
    );
    final phone = _whatsappNumber(_phoneCtrl.text);
    final uri = Uri.parse(
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) AppAlerts.error(context, l10n.couldNotOpenWhatsapp);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_phoneCtrl.text.trim().length < 7) {
      AppAlerts.error(context, l10n.phoneInvalidError);
      return;
    }
    final provider = context.read<TraineeProvider>();
    try {
      await provider.addTrainee(CreateTraineeRequest(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        goal: _selectedGoal,
        heightCm: double.tryParse(_heightCtrl.text) ?? 170,
        currentWeightKg: double.tryParse(_weightCtrl.text) ?? 70,
      ));
      if (!mounted) return;

      // Offer to send the welcome message + credentials on WhatsApp.
      final send = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.colors.card,
          title: Text(l10n.whatsappWelcomeTitle,
              style: TextStyle(
                  color: context.colors.fg, fontWeight: FontWeight.w700)),
          content: Text(
              l10n.whatsappWelcomeBody(_firstNameCtrl.text.trim()),
              style: TextStyle(color: context.colors.subFg)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.skip,
                  style: TextStyle(color: context.colors.subFg)),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
              label: Text(l10n.sendOnWhatsapp,
                  style: const TextStyle(
                      color: Color(0xFF25D366), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

      if (send == true) await _sendWhatsAppWelcome();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) AppAlerts.handleError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<TraineeProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.addTrainee,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RoundTextField(
              textEditingController: _firstNameCtrl,
              hintText: l10n.firstName,
              icon: "assets/icons/profile_icon.png",
              textInputType: TextInputType.name,
            ),
            const SizedBox(height: 15),
            RoundTextField(
              textEditingController: _lastNameCtrl,
              hintText: l10n.lastName,
              icon: "assets/icons/profile_icon.png",
              textInputType: TextInputType.name,
            ),
            const SizedBox(height: 15),
            RoundTextField(
              textEditingController: _emailCtrl,
              hintText: l10n.email,
              icon: "assets/icons/message_icon.png",
              textInputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            RoundTextField(
              textEditingController: _phoneCtrl,
              hintText: l10n.phoneNumber,
              icon: "assets/icons/profile_icon.png",
              textInputType: TextInputType.phone,
              rightIcon: IconButton(
                tooltip: l10n.pickFromContacts,
                onPressed: _pickFromContacts,
                icon: const Icon(Icons.contacts_rounded,
                    color: AppColors.primaryColor1, size: 22),
              ),
            ),
            const SizedBox(height: 15),
            RoundTextField(
              textEditingController: _passwordCtrl,
              hintText: l10n.tempPassword,
              icon: "assets/icons/lock_icon.png",
              textInputType: TextInputType.text,
              isObscureText: _obscure,
              rightIcon: TextButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: colors.subFg, size: 20,
                ),
              ),
            ),
            const SizedBox(height: 15),
            RoundTextField(
              textEditingController: _heightCtrl,
              hintText: l10n.heightCm,
              icon: "assets/icons/profile_icon.png",
              textInputType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            RoundTextField(
              textEditingController: _weightCtrl,
              hintText: l10n.weightKg,
              icon: "assets/icons/profile_icon.png",
              textInputType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Text(l10n.goal,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: colors.fg)),
            const SizedBox(height: 10),
            Row(
              children: _goals.map((goal) {
                final selected = _selectedGoal == goal;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGoal = goal),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? LinearGradient(colors: AppColors.primaryG)
                            : null,
                        color: selected ? null : colors.listTile,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(goalLabel(l10n, goal),
                          style: TextStyle(
                            color: selected ? Colors.white : colors.subFg,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            provider.loading
                ? const LiaqhPageLoader()
                : RoundGradientButton(title: l10n.addTrainee, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
