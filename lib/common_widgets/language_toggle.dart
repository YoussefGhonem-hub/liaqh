import 'package:fitnessapp/providers/language_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return GestureDetector(
      onTap: () => context.read<LanguageProvider>().toggleLanguage(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryG),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              lang.isArabic ? 'EN' : 'عربي',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.language, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
