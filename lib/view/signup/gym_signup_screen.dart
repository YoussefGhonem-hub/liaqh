import 'dart:io';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class GymSignupScreen extends StatefulWidget {
  static const routeName = '/GymSignupScreen';
  const GymSignupScreen({Key? key}) : super(key: key);

  @override
  State<GymSignupScreen> createState() => _GymSignupScreenState();
}

class _GymSignupScreenState extends State<GymSignupScreen> {
  int _step = 0; // 0 = gym info, 1 = admin account

  // Step 1
  final _gymNameCtrl = TextEditingController();
  File? _logoFile;

  // Step 2
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _obscure = true;
  String? _validationError;

  @override
  void dispose() {
    _gymNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (picked != null) setState(() => _logoFile = File(picked.path));
  }

  void _nextStep() {
    final l10n = AppLocalizations.of(context);
    if (_gymNameCtrl.text.trim().isEmpty) {
      setState(() => _validationError = l10n.gymNameRequired);
      return;
    }
    setState(() {
      _validationError = null;
      _step = 1;
    });
  }

  String? _validateStep2(AppLocalizations l10n) {
    if (_firstNameCtrl.text.trim().isEmpty) return l10n.errorRequired;
    if (_lastNameCtrl.text.trim().isEmpty) return l10n.errorRequired;
    if (!_emailCtrl.text.contains('@')) return l10n.errorInvalidEmail;
    if (_passwordCtrl.text.length < 6) return l10n.errorMinPassword;
    if (_phoneCtrl.text.trim().length < 7) return l10n.phoneInvalidError;
    return null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final err = _validateStep2(l10n);
    if (err != null) {
      setState(() => _validationError = err);
      return;
    }
    setState(() => _validationError = null);

    final auth = context.read<AuthProvider>();
    final ok = await auth.registerGym(
      gymName: _gymNameCtrl.text.trim(),
      adminEmail: _emailCtrl.text.trim(),
      adminPassword: _passwordCtrl.text,
      adminFirstName: _firstNameCtrl.text.trim(),
      adminLastName: _lastNameCtrl.text.trim(),
      adminPhone: _phoneCtrl.text.trim(),
      logo: _logoFile,
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
          onPressed: () {
            if (_step == 1) {
              setState(() {
                _step = 0;
                _validationError = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _step == 0 ? l10n.gymDetails : l10n.adminAccount,
          style: TextStyle(
            color: colors.fg,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _step == 0 ? 0.5 : 1.0,
            backgroundColor: AppColors.lightGrayColor,
            color: AppColors.primaryColor1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: _step == 0
              ? _buildStep1(media, l10n, colors)
              : _buildStep2(media, auth, l10n, colors),
        ),
      ),
    );
  }

  Widget _buildStep1(Size media, AppLocalizations l10n, AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: media.width * 0.03),
        Text(
          l10n.gymDetails,
          style: TextStyle(
            color: colors.fg,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: media.width * 0.06),

        // Logo picker
        Center(
          child: GestureDetector(
            onTap: _pickLogo,
            child: Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: colors.listTile,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _logoFile != null
                          ? AppColors.primaryColor1
                          : colors.subFg.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    image: _logoFile != null
                        ? DecorationImage(
                            image: FileImage(_logoFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _logoFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_outlined,
                                color: AppColors.primaryColor1, size: 32),
                            const SizedBox(height: 6),
                            Text(
                              l10n.gymLogo,
                              style: TextStyle(
                                  color: colors.subFg, fontSize: 12),
                            ),
                          ],
                        )
                      : null,
                ),
                if (_logoFile != null)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor1,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit,
                          color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            l10n.gymLogoDesc,
            style: TextStyle(color: colors.subFg, fontSize: 12),
          ),
        ),
        SizedBox(height: media.width * 0.06),

        RoundTextField(
          textEditingController: _gymNameCtrl,
          hintText: l10n.gymNameHint,
          icon: 'assets/icons/user_icon.png',
          textInputType: TextInputType.text,
        ),

        if (_validationError != null) ...[
          SizedBox(height: media.width * 0.03),
          Text(
            _validationError!,
            style:
                const TextStyle(color: AppColors.errorColor, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],

        SizedBox(height: media.width * 0.06),
        RoundGradientButton(title: l10n.next, onPressed: _nextStep),
        SizedBox(height: media.width * 0.04),
      ],
    );
  }

  Widget _buildStep2(Size media, AuthProvider auth, AppLocalizations l10n, AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: media.width * 0.03),
        Text(
          l10n.adminAccount,
          style: TextStyle(
            color: colors.fg,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          l10n.adminAccountDesc,
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
            style:
                const TextStyle(color: AppColors.errorColor, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: media.width * 0.06),
        auth.loading
            ? const LiaqhPageLoader()
            : RoundGradientButton(
                title: l10n.createGym,
                onPressed: _submit,
              ),
        SizedBox(height: media.width * 0.04),
      ],
    );
  }
}
