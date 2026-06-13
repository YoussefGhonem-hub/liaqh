import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/dashboard/dashboard_screen.dart';
import 'package:fitnessapp/view/signup/account_type_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:fitnessapp/utils/liaqh_icon.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/LoginScreen";
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onInputChanged);
    _passwordController.addListener(_onInputChanged);
  }

  void _onInputChanged() => setState(() {});

  bool get _canSubmit =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final media = MediaQuery.of(context).size;
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: SizedBox(
            height: media.height - MediaQuery.of(context).padding.top - 30,
            child: Column(
              children: [
                SizedBox(height: media.width * 0.04),
                LiaqhIcon(size: media.width * 0.28),
                SizedBox(height: media.width * 0.04),
                Text(
                  l10n.heyThere,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.subFg, fontSize: 15),
                ),
                SizedBox(height: media.width * 0.01),
                Text(
                  l10n.welcomeBack,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.fg,
                    fontSize: 22,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: media.width * 0.06),
                RoundTextField(
                  textEditingController: _emailController,
                  hintText: l10n.email,
                  icon: "assets/icons/message_icon.png",
                  textInputType: TextInputType.emailAddress,
                ),
                SizedBox(height: media.width * 0.05),
                RoundTextField(
                  textEditingController: _passwordController,
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
                if (auth.error != null) ...[
                  SizedBox(height: media.width * 0.03),
                  Text(
                    auth.error!,
                    style: const TextStyle(color: AppColors.errorColor, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
                const Spacer(),
                auth.loading
                    ? const CircularProgressIndicator()
                    : RoundGradientButton(
                        title: l10n.login,
                        onPressed: _canSubmit ? _login : null,
                      ),
                SizedBox(height: media.width * 0.04),
                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: colors.subFg.withValues(alpha: 0.5))),
                    Text("  ${l10n.or}  ",
                        style: TextStyle(color: colors.subFg, fontSize: 12)),
                    Expanded(child: Container(height: 1, color: colors.subFg.withValues(alpha: 0.5))),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AccountTypeScreen.routeName),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: colors.fg, fontSize: 14),
                      children: [
                        TextSpan(text: l10n.noAccount),
                        TextSpan(
                          text: l10n.register,
                          style: const TextStyle(
                            color: AppColors.secondaryColor1,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Developed by Youssef Ghonem',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: colors.subFg,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
