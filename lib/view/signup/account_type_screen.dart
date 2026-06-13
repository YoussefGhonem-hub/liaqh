import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/signup/individual_coach_signup_screen.dart';
import 'package:fitnessapp/view/signup/gym_signup_screen.dart';
import 'package:flutter/material.dart';

class AccountTypeScreen extends StatelessWidget {
  static const routeName = '/AccountTypeScreen';
  const AccountTypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final media = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: media.width * 0.08),
              Text(
                l10n.heyThere,
                style: TextStyle(color: colors.fg, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.getStarted,
                style: TextStyle(
                  color: colors.fg,
                  fontSize: 20,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.chooseAccountType,
                style: TextStyle(color: colors.subFg, fontSize: 14),
              ),
              SizedBox(height: media.width * 0.1),

              _TypeCard(
                icon: Icons.person_outline_rounded,
                title: l10n.individualCoach,
                subtitle: l10n.individualCoachDesc,
                onTap: () => Navigator.pushNamed(
                    context, IndividualCoachSignupScreen.routeName),
              ),
              const SizedBox(height: 20),
              _TypeCard(
                icon: Icons.corporate_fare_rounded,
                title: l10n.gym,
                subtitle: l10n.gymDesc,
                onTap: () =>
                    Navigator.pushNamed(context, GymSignupScreen.routeName),
              ),

              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.alreadyAccount,
                    style: TextStyle(color: colors.fg, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      '',
                      style: TextStyle(
                        color: AppColors.primaryColor1,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      l10n.signIn,
                      style: const TextStyle(
                        color: AppColors.primaryColor1,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: media.width * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.listTile,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.grayColor.withValues(alpha: 0.15), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryColor1, AppColors.primaryColor2],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.fg,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colors.subFg,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.primaryColor1, size: 16),
          ],
        ),
      ),
    );
  }
}
