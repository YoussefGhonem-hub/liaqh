import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/guide/coach_guide_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// First-time, swipeable welcome tour shown once after a user registers / first
/// opens the app. Explains the app at a high level and points to the Coach
/// Guide for full details. Persisted via SharedPreferences so it shows once.
class AppTour {
  static const _seenKey = 'app_tour_seen_v1';

  /// Shows the tour once. Pass [isCoach] to include coach-focused slides.
  static Future<void> maybeShow(BuildContext context,
      {required bool isCoach}) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seenKey) == true) return;
    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => _TourDialog(isCoach: isCoach),
    );
    await prefs.setBool(_seenKey, true);
  }
}

class _TourSlide {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String body;
  const _TourSlide(this.icon, this.gradient, this.title, this.body);
}

class _TourDialog extends StatefulWidget {
  final bool isCoach;
  const _TourDialog({required this.isCoach});

  @override
  State<_TourDialog> createState() => _TourDialogState();
}

class _TourDialogState extends State<_TourDialog> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_TourSlide> _slides(AppLocalizations l10n) {
    return [
      _TourSlide(Icons.waving_hand_rounded, AppColors.primaryG,
          l10n.tourWelcomeTitle, l10n.tourWelcomeBody),
      if (widget.isCoach) ...[
        const _TourSlide(Icons.restaurant_menu_rounded,
            [Color(0xFF43A047), Color(0xFF1B5E20)], '', ''),
        const _TourSlide(Icons.fitness_center_rounded,
            [Color(0xFF6366F1), Color(0xFF4338CA)], '', ''),
        const _TourSlide(Icons.insights_rounded,
            [Color(0xFFF59E0B), Color(0xFFB45309)], '', ''),
        const _TourSlide(Icons.menu_book_rounded,
            [Color(0xFFD97757), Color(0xFFB85C38)], '', ''),
      ],
    ];
  }

  // Resolve text for coach slides (kept here so const slides stay simple).
  ({String title, String body}) _text(AppLocalizations l10n, int index) {
    switch (index) {
      case 1:
        return (title: l10n.tourNutritionTitle, body: l10n.tourNutritionBody);
      case 2:
        return (title: l10n.tourWorkoutsTitle, body: l10n.tourWorkoutsBody);
      case 3:
        return (title: l10n.tourTrackTitle, body: l10n.tourTrackBody);
      case 4:
        return (title: l10n.tourGuideTitle, body: l10n.tourGuideBody);
      default:
        return (title: l10n.tourWelcomeTitle, body: l10n.tourWelcomeBody);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final slides = _slides(l10n);
    final isLast = _page == slides.length - 1;

    return Dialog(
      backgroundColor: colors.card,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Skip
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.tourSkip,
                    style: TextStyle(color: colors.subFg)),
              ),
            ),
            SizedBox(
              height: 320,
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final s = slides[i];
                  final text = _text(l10n, i);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: s.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: s.gradient.first.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Icon(s.icon, color: Colors.white, size: 44),
                      ),
                      const SizedBox(height: 24),
                      Text(text.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: colors.fg)),
                      const SizedBox(height: 12),
                      Text(text.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, height: 1.5, color: colors.subFg)),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _page == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? AppColors.primaryColor1
                        : colors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isLast) {
                    final goGuide = widget.isCoach;
                    Navigator.pop(context);
                    if (goGuide) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CoachGuideScreen()),
                      );
                    }
                  } else {
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor1,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size(0, 50),
                ),
                child: Text(isLast ? l10n.tourDone : l10n.tourNext,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            if (isLast && widget.isCoach) ...[
              const SizedBox(height: 8),
              Text(l10n.tourReopenHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: colors.subFg)),
            ],
          ],
        ),
      ),
    );
  }
}
