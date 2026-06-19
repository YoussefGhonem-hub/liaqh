import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';

/// A step-by-step guide that explains how a coach uses the system: the overall
/// journey plus how to create nutrition plans, workouts, and subscriptions.
/// Opened from the side menu, and linked from the first-time app tour.
class CoachGuideScreen extends StatelessWidget {
  const CoachGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.coachGuide,
            style: TextStyle(
                fontWeight: FontWeight.w700, color: colors.fg, fontSize: 17)),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Hero header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryG,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primaryColor1.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.menu_book_rounded,
                    color: Colors.white, size: 32),
                const SizedBox(height: 12),
                Text(l10n.coachGuide,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22)),
                const SizedBox(height: 6),
                Text(l10n.guideHeaderSubtitle,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Full journey
          _GuideCard(
            icon: Icons.route_rounded,
            color: AppColors.primaryColor1,
            title: l10n.guideProcessTitle,
            steps: [
              l10n.guideProcessStep1,
              l10n.guideProcessStep2,
              l10n.guideProcessStep3,
              l10n.guideProcessStep4,
              l10n.guideProcessStep5,
            ],
          ),
          const SizedBox(height: 16),

          _GuideCard(
            icon: Icons.restaurant_menu_rounded,
            color: const Color(0xFF43A047),
            title: l10n.guideNutritionTitle,
            steps: [
              l10n.guideNutritionStep1,
              l10n.guideNutritionStep2,
              l10n.guideNutritionStep3,
              l10n.guideNutritionStep4,
              l10n.guideNutritionStep5,
              l10n.guideNutritionStep6,
            ],
          ),
          const SizedBox(height: 16),

          _GuideCard(
            icon: Icons.fitness_center_rounded,
            color: const Color(0xFF6366F1),
            title: l10n.guideWorkoutsTitle,
            steps: [
              l10n.guideWorkoutsStep1,
              l10n.guideWorkoutsStep2,
              l10n.guideWorkoutsStep3,
              l10n.guideWorkoutsStep4,
            ],
          ),
          const SizedBox(height: 16),

          _GuideCard(
            icon: Icons.workspace_premium_rounded,
            color: const Color(0xFFF59E0B),
            title: l10n.guideSubscriptionsTitle,
            steps: [
              l10n.guideSubscriptionsStep1,
              l10n.guideSubscriptionsStep2,
              l10n.guideSubscriptionsStep3,
            ],
          ),
          const SizedBox(height: 16),

          // Pro tips
          _TipsCard(
            title: l10n.guideTipsTitle,
            tips: [l10n.guideTip1, l10n.guideTip2, l10n.guideTip3],
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<String> steps;
  const _GuideCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: colors.fg)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(steps.length, (i) {
            final isLast = i == steps.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            color,
                            color.withValues(alpha: 0.7),
                          ]),
                          shape: BoxShape.circle,
                        ),
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12)),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: color.withValues(alpha: 0.25),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 14, top: 3),
                      child: Text(steps[i],
                          style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: colors.fg)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  final String title;
  final List<String> tips;
  const _TipsCard({required this.title, required this.tips});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor1.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppColors.primaryColor1.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  color: AppColors.primaryColor1, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: colors.fg)),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.primaryColor1, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(t,
                          style: TextStyle(
                              fontSize: 13, height: 1.4, color: colors.fg)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
