import 'package:fitnessapp/providers/language_provider.dart';
import 'package:fitnessapp/view/welcome/welcome_landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// First-launch language picker (matches the design prototype).
class LanguageSelectScreen extends StatelessWidget {
  static const routeName = '/LanguageSelectScreen';
  const LanguageSelectScreen({super.key});

  static const _bg = Color(0xFF1C1714);
  static const _surface = Color(0xFF211A16);
  static const _orange = Color(0xFFD97757);
  static const _text = Color(0xFFFAF6F2);
  static const _muted = Color(0xFF6B5E57);

  Future<void> _select(BuildContext context, String code) async {
    await context.read<LanguageProvider>().setLocale(Locale(code), markChosen: true);
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, WelcomeLandingScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('CHOOSE YOUR LANGUAGE',
                  style: TextStyle(
                      color: _muted, fontSize: 13, letterSpacing: 3)),
              const SizedBox(height: 4),
              const Text('اختر لغتك',
                  style: TextStyle(color: _muted, fontSize: 13)),
              const SizedBox(height: 28),
              _LangCard(
                flag: '🇸🇦',
                title: 'العربية',
                subtitle: 'Arabic',
                onTap: () => _select(context, 'ar'),
              ),
              const SizedBox(height: 16),
              _LangCard(
                flag: '🇺🇸',
                title: 'English',
                subtitle: 'الإنجليزية',
                onTap: () => _select(context, 'en'),
              ),
              const SizedBox(height: 20),
              const Text('You can change this later in settings',
                  style: TextStyle(color: _muted, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangCard extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _LangCard({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: LanguageSelectScreen._surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: LanguageSelectScreen._orange.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LanguageSelectScreen._bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(flag, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: LanguageSelectScreen._text,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    Text(subtitle,
                        style: const TextStyle(
                            color: LanguageSelectScreen._muted, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LanguageSelectScreen._orange.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    size: 14, color: LanguageSelectScreen._orange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
