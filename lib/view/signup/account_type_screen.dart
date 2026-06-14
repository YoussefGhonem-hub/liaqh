import 'package:fitnessapp/common_widgets/liaqh_logo.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/signup/individual_coach_signup_screen.dart';
import 'package:fitnessapp/view/signup/gym_signup_screen.dart';
import 'package:flutter/material.dart';

class AccountTypeScreen extends StatelessWidget {
  static const routeName = '/AccountTypeScreen';
  const AccountTypeScreen({Key? key}) : super(key: key);

  // Auth screens follow the dark design palette.
  static const _bg = Color(0xFF1C1714);
  static const _text = Color(0xFFFAF6F2);
  static const _muted = Color(0xFF6B5E57);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + logo
              Row(
                children: [
                  _BackBtn(isAr: isAr, onTap: () => Navigator.pop(context)),
                  const Spacer(),
                  const LiaqhWordmark(flameSize: 22, fontSize: 18),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 36),
              Text(l10n.heyThere,
                  style: const TextStyle(color: _muted, fontSize: 15)),
              const SizedBox(height: 4),
              Text(l10n.getStarted,
                  style: const TextStyle(
                      color: _text, fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(l10n.chooseAccountType,
                  style: const TextStyle(color: _muted, fontSize: 14)),
              const SizedBox(height: 32),

              _TypeCard(
                icon: Icons.person_rounded,
                title: l10n.individualCoach,
                subtitle: l10n.individualCoachDesc,
                accent: AppColors.primaryColor1,
                accentLight: AppColors.primaryColor2,
                isAr: isAr,
                onTap: () => Navigator.pushNamed(
                    context, IndividualCoachSignupScreen.routeName),
              ),
              const SizedBox(height: 18),
              _TypeCard(
                icon: Icons.fitness_center_rounded,
                title: l10n.gym,
                subtitle: l10n.gymDesc,
                accent: const Color(0xFF6366F1),
                accentLight: const Color(0xFF8B5CF6),
                isAr: isAr,
                onTap: () =>
                    Navigator.pushNamed(context, GymSignupScreen.routeName),
              ),

              const Spacer(),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: _text, fontSize: 14),
                      children: [
                        TextSpan(text: l10n.alreadyAccount),
                        TextSpan(
                          text: l10n.signIn,
                          style: const TextStyle(
                              color: AppColors.primaryColor1,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackBtn extends StatelessWidget {
  final bool isAr;
  final VoidCallback onTap;
  const _BackBtn({required this.isAr, required this.onTap});

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
          child: Icon(
              isAr ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
              color: const Color(0xFFFAF6F2),
              size: 20),
        ),
      );
}

class _TypeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Color accentLight;
  final bool isAr;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.accentLight,
    required this.isAr,
    required this.onTap,
  });

  @override
  State<_TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<_TypeCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: const Duration(milliseconds: 110),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.accent.withValues(alpha: 0.16),
                widget.accent.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: widget.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              // Gradient icon badge
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.accent, widget.accentLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accent.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            color: Color(0xFFFAF6F2),
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(widget.subtitle,
                        style: const TextStyle(
                            color: Color(0xFFC4B5AA),
                            fontSize: 12,
                            height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accent.withValues(alpha: 0.18),
                ),
                child: Icon(
                    widget.isAr
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: widget.accent,
                    size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
