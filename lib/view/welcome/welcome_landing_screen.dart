import 'package:fitnessapp/common_widgets/app_button.dart';
import 'package:fitnessapp/common_widgets/liaqh_logo.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/view/login/login_screen.dart';
import 'package:fitnessapp/view/signup/account_type_screen.dart';
import 'package:flutter/material.dart';

/// App entry landing — hero image, headline, Login + "I'm new here".
/// Matches the design prototype's Welcome screen.
class WelcomeLandingScreen extends StatelessWidget {
  static const routeName = '/WelcomeLandingScreen';
  const WelcomeLandingScreen({super.key});

  static const _bg = Color(0xFF1C1714);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // Hero
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=780&h=1040&fit=crop&auto=format',
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(alpha: 0.45),
                  colorBlendMode: BlendMode.darken,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2A221E), _bg],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Dark fade to bottom
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.4, 0.85, 1.0],
                      colors: [
                        Color(0x4D1C1714),
                        Color(0x001C1714),
                        Color(0xE61C1714),
                        Color(0xFF1C1714),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  top: 56,
                  left: 0,
                  right: 0,
                  child: Center(child: LiaqhWordmark()),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr
                            ? 'رحلتك نحو اللياقة تبدأ هنا'
                            : 'Your Fitness Journey\nStarts Here',
                        style: const TextStyle(
                          color: Color(0xFFFAF6F2),
                          fontSize: 26,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAr
                            ? 'تواصل مع كوتشك وتتبع تقدمك كل يوم'
                            : 'Connect with your coach and track progress daily',
                        style: const TextStyle(
                            color: Color(0xFFC4B5AA), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // CTAs
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              children: [
                AppButton(
                  label: l10n.login,
                  onPressed: () =>
                      Navigator.pushNamed(context, LoginScreen.routeName),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: isAr ? 'أنا جديد هنا' : "I'm new here",
                  secondary: true,
                  onPressed: () => Navigator.pushNamed(
                      context, AccountTypeScreen.routeName),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
