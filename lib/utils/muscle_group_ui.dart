import 'package:flutter/material.dart';

// Muscle-group → color gradient + icon
// Used in exercise cards and session screen headers.

class MuscleGroupStyle {
  final List<Color> gradient;
  final IconData icon;
  final String label;
  final String labelAr;

  const MuscleGroupStyle({
    required this.gradient,
    required this.icon,
    required this.label,
    required this.labelAr,
  });
}

const _styles = <String, MuscleGroupStyle>{
  'Chest': MuscleGroupStyle(
    gradient: [Color(0xFFFF6B35), Color(0xFFFF4500)],
    icon: Icons.fitness_center,
    label: 'Chest',
    labelAr: 'صدر',
  ),
  'Back': MuscleGroupStyle(
    gradient: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
    icon: Icons.arrow_back,
    label: 'Back',
    labelAr: 'ظهر',
  ),
  'Shoulders': MuscleGroupStyle(
    gradient: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
    icon: Icons.accessibility_new,
    label: 'Shoulders',
    labelAr: 'أكتاف',
  ),
  'Biceps': MuscleGroupStyle(
    gradient: [Color(0xFF00897B), Color(0xFF00695C)],
    icon: Icons.sports_gymnastics,
    label: 'Biceps',
    labelAr: 'باي',
  ),
  'Triceps': MuscleGroupStyle(
    gradient: [Color(0xFF43A047), Color(0xFF2E7D32)],
    icon: Icons.sports_gymnastics,
    label: 'Triceps',
    labelAr: 'تراي',
  ),
  'Abs': MuscleGroupStyle(
    gradient: [Color(0xFFE53935), Color(0xFFB71C1C)],
    icon: Icons.grain,
    label: 'Core / Abs',
    labelAr: 'بطن / جذع',
  ),
  'Quads': MuscleGroupStyle(
    gradient: [Color(0xFFF9A825), Color(0xFFE65100)],
    icon: Icons.directions_walk,
    label: 'Quads',
    labelAr: 'كواد',
  ),
  'Hamstrings': MuscleGroupStyle(
    gradient: [Color(0xFFFF8F00), Color(0xFFE65100)],
    icon: Icons.directions_walk,
    label: 'Hamstrings',
    labelAr: 'أوتار الركبة',
  ),
  'Glutes': MuscleGroupStyle(
    gradient: [Color(0xFFAD1457), Color(0xFF880E4F)],
    icon: Icons.directions_walk,
    label: 'Glutes',
    labelAr: 'مؤخرة',
  ),
  'Calves': MuscleGroupStyle(
    gradient: [Color(0xFF6D4C41), Color(0xFF4E342E)],
    icon: Icons.directions_walk,
    label: 'Calves',
    labelAr: 'سمانة',
  ),
  'Legs': MuscleGroupStyle(
    gradient: [Color(0xFFF9A825), Color(0xFFE65100)],
    icon: Icons.directions_walk,
    label: 'Legs',
    labelAr: 'أرجل',
  ),
  'FullBody': MuscleGroupStyle(
    gradient: [Color(0xFFE91E63), Color(0xFF880E4F)],
    icon: Icons.directions_run,
    label: 'Cardio',
    labelAr: 'كارديو',
  ),
  'UpperBody': MuscleGroupStyle(
    gradient: [Color(0xFF546E7A), Color(0xFF263238)],
    icon: Icons.accessibility_new,
    label: 'Upper Body',
    labelAr: 'جزء علوي',
  ),
  'LowerBody': MuscleGroupStyle(
    gradient: [Color(0xFF5D4037), Color(0xFF3E2723)],
    icon: Icons.directions_walk,
    label: 'Lower Body',
    labelAr: 'جزء سفلي',
  ),
  'Push': MuscleGroupStyle(
    gradient: [Color(0xFFFF6B35), Color(0xFFFF4500)],
    icon: Icons.fitness_center,
    label: 'Push',
    labelAr: 'دفع',
  ),
  'Pull': MuscleGroupStyle(
    gradient: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
    icon: Icons.fitness_center,
    label: 'Pull',
    labelAr: 'سحب',
  ),
  'Forearms': MuscleGroupStyle(
    gradient: [Color(0xFF00ACC1), Color(0xFF006064)],
    icon: Icons.sports_gymnastics,
    label: 'Forearms',
    labelAr: 'ساعد',
  ),
};

MuscleGroupStyle muscleGroupStyle(String muscleGroup) =>
    _styles[muscleGroup] ??
    const MuscleGroupStyle(
      gradient: [Color(0xFF78909C), Color(0xFF455A64)],
      icon: Icons.fitness_center,
      label: 'Exercise',
      labelAr: 'تمرين',
    );

// Animated header widget used on session screen and exercise cards.
class MuscleGroupBanner extends StatelessWidget {
  final String muscleGroup;
  final String exerciseName;
  final String? exerciseNameAr;
  final double height;

  const MuscleGroupBanner({
    super.key,
    required this.muscleGroup,
    required this.exerciseName,
    this.exerciseNameAr,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final style = muscleGroupStyle(muscleGroup);
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: style.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Big faded icon as background texture
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(style.icon,
                size: 90,
                color: Colors.white.withValues(alpha: 0.15)),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(style.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                Text(exerciseName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                if (exerciseNameAr != null)
                  Text(exerciseNameAr!,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Small colored badge used in exercise list cards.
class MuscleGroupBadge extends StatelessWidget {
  final String muscleGroup;
  const MuscleGroupBadge({super.key, required this.muscleGroup});

  @override
  Widget build(BuildContext context) {
    final style = muscleGroupStyle(muscleGroup);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: style.gradient),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 10, color: Colors.white),
          const SizedBox(width: 4),
          Text(style.label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
