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

class IndividualCoachSignupScreen extends StatefulWidget {
  static const routeName = '/IndividualCoachSignupScreen';
  const IndividualCoachSignupScreen({Key? key}) : super(key: key);

  @override
  State<IndividualCoachSignupScreen> createState() =>
      _IndividualCoachSignupScreenState();
}

class _IndividualCoachSignupScreenState
    extends State<IndividualCoachSignupScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _obscure = true;
  String? _validationError;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String? _validate(AppLocalizations l10n) {
    if (_firstNameCtrl.text.trim().isEmpty) return l10n.errorRequired;
    if (_lastNameCtrl.text.trim().isEmpty) return l10n.errorRequired;
    if (!_emailCtrl.text.contains('@')) return l10n.errorInvalidEmail;
    if (_passwordCtrl.text.length < 6) return l10n.errorMinPassword;
    return null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final err = _validate(l10n);
    if (err != null) {
      setState(() => _validationError = err);
      return;
    }
    setState(() => _validationError = null);

    final auth = context.read<AuthProvider>();
    final ok = await auth.registerIndividualCoach(
      RegisterIndividualCoachRequest(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phoneNumber:
            _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      ),
    );
    if (ok && mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, DashboardScreen.routeName, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final auth = context.watch<AuthProvider>();
    final media = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.fg),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.individualCoach,
          style: TextStyle(
            color: colors.fg,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: media.width * 0.03),
              Text(
                l10n.createYourAccount,
                style: TextStyle(
                  color: colors.fg,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.personalGymNote,
                style: TextStyle(color: colors.subFg, fontSize: 13),
              ),
              SizedBox(height: media.width * 0.05),
              RoundTextField(
                textEditingController: _firstNameCtrl,
                hintText: l10n.firstName,
                icon: 'assets/icons/user_icon.png',
                textInputType: TextInputType.name,
              ),
              SizedBox(height: media.width * 0.04),
              RoundTextField(
                textEditingController: _lastNameCtrl,
                hintText: l10n.lastName,
                icon: 'assets/icons/user_icon.png',
                textInputType: TextInputType.name,
              ),
              SizedBox(height: media.width * 0.04),
              RoundTextField(
                textEditingController: _emailCtrl,
                hintText: l10n.email,
                icon: 'assets/icons/message_icon.png',
                textInputType: TextInputType.emailAddress,
              ),
              SizedBox(height: media.width * 0.04),
              RoundTextField(
                textEditingController: _passwordCtrl,
                hintText: l10n.password,
                icon: 'assets/icons/lock_icon.png',
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
              SizedBox(height: media.width * 0.04),
              RoundTextField(
                textEditingController: _phoneCtrl,
                hintText: l10n.phoneNumber,
                icon: 'assets/icons/user_icon.png',
                textInputType: TextInputType.phone,
              ),
              if (_validationError != null || auth.error != null) ...[
                SizedBox(height: media.width * 0.03),
                Text(
                  _validationError ?? auth.error!,
                  style: const TextStyle(
                      color: AppColors.errorColor, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: media.width * 0.06),
              auth.loading
                  ? const Center(child: CircularProgressIndicator())
                  : RoundGradientButton(
                      title: l10n.createAccount,
                      onPressed: _submit,
                    ),
              SizedBox(height: media.width * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
