import 'package:fitnessapp/common_widgets/app_button.dart';
import 'package:fitnessapp/common_widgets/liaqh_logo.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/view/dashboard/dashboard_screen.dart';
import 'package:fitnessapp/view/signup/account_type_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

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

  // Design palette (these auth screens are dark by design).
  static const _bg = Color(0xFF1C1714);
  static const _text = Color(0xFFFAF6F2);
  static const _muted = Color(0xFF6B5E57);

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
    final success = await LiaqhLoading.during(
      context,
      () => auth.login(
        _emailController.text.trim(),
        _passwordController.text,
      ),
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + logo
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.canPop(context)
                        ? Navigator.pop(context)
                        : null,
                  ),
                  const Spacer(),
                  const LiaqhWordmark(flameSize: 22, fontSize: 18),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 32),
              Text(l10n.welcomeBack,
                  style: const TextStyle(
                      color: _text, fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(l10n.heyThere,
                  style: const TextStyle(color: _muted, fontSize: 14)),
              const SizedBox(height: 28),

              // Email
              _Field(
                controller: _emailController,
                hint: l10n.emailOrPhone,
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              // Password
              _Field(
                controller: _passwordController,
                hint: l10n.password,
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                trailing: IconButton(
                  icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _muted,
                      size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () {},
                  child: Text(l10n.forgotPassword,
                      style: const TextStyle(
                          color: AppColors.primaryColor1, fontSize: 13)),
                ),
              ),

              if (auth.error != null) ...[
                const SizedBox(height: 4),
                Text(
                    auth.error!.toLowerCase().contains('connect')
                        ? auth.error!
                        : l10n.invalidCredentials,
                    style: const TextStyle(
                        color: AppColors.errorColor, fontSize: 12)),
              ],
              const SizedBox(height: 16),

              AppButton(
                label: l10n.signIn,
                loading: auth.loading,
                onPressed: _canSubmit ? _login : null,
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0x4D6B5E57))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(l10n.or,
                        style: const TextStyle(color: _muted, fontSize: 12)),
                  ),
                  const Expanded(child: Divider(color: Color(0x4D6B5E57))),
                ],
              ),
              const SizedBox(height: 16),

              // Register CTA
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(
                      context, AccountTypeScreen.routeName),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: _text, fontSize: 14),
                      children: [
                        TextSpan(text: l10n.noAccount),
                        TextSpan(
                          text: l10n.register,
                          style: const TextStyle(
                              color: AppColors.primaryColor1,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text('Developed by Youssef Ghonem',
                    style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF211A16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFFAF6F2), size: 20),
        ),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? trailing;
  final TextInputType? keyboardType;
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.trailing,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFFFAF6F2), fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B5E57)),
        prefixIcon: Icon(icon, color: const Color(0xFF6B5E57), size: 20),
        suffixIcon: trailing,
        filled: true,
        fillColor: const Color(0xFF211A16),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x4D6B5E57), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primaryColor1, width: 1.5),
        ),
      ),
    );
  }
}
