import 'package:fitnessapp/data/models/trainee_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/trainee_provider.dart';
import 'package:fitnessapp/utils/app_alerts.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/utils/nutrition_l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      if (mounted) {
        AppAlerts.success(context, 'Trainee added successfully.');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      }
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
