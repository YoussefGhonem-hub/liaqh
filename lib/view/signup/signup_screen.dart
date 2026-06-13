import 'package:fitnessapp/data/models/auth_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class SignupScreen extends StatefulWidget {
  static String routeName = "/SignupScreen";
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _gymIdCtrl = TextEditingController();
  bool _obscure = true;
  bool _agreed = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _gymIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms to continue.')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.registerCoach(RegisterCoachRequest(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      gymId: _gymIdCtrl.text.trim(),
    ));
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Text(l10n.heyThere,
                  style: TextStyle(color: colors.fg, fontSize: 16)),
              const SizedBox(height: 5),
              Text(l10n.createAccount,
                  style: TextStyle(
                    color: colors.fg,
                    fontSize: 20,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 15),
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
                textEditingController: _passwordCtrl,
                hintText: l10n.password,
                icon: "assets/icons/lock_icon.png",
                textInputType: TextInputType.text,
                isObscureText: _obscure,
                rightIcon: TextButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: colors.subFg,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              RoundTextField(
                textEditingController: _gymIdCtrl,
                hintText: l10n.gymId,
                icon: "assets/icons/profile_icon.png",
                textInputType: TextInputType.text,
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 10),
                Text(auth.error!,
                    style: const TextStyle(color: AppColors.errorColor, fontSize: 12),
                    textAlign: TextAlign.center),
              ],
              const SizedBox(height: 15),
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _agreed = !_agreed),
                    icon: Icon(
                      _agreed ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined,
                      color: AppColors.primaryColor1,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l10n.termsText,
                      style: TextStyle(color: colors.subFg, fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              auth.loading
                  ? const CircularProgressIndicator()
                  : RoundGradientButton(title: l10n.register, onPressed: _register),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: colors.fg, fontSize: 14),
                    children: [
                      TextSpan(text: l10n.alreadyAccount),
                      TextSpan(
                        text: l10n.login,
                        style: const TextStyle(
                          color: AppColors.secondaryColor1,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
