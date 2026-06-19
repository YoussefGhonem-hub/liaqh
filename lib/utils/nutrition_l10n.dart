import 'package:flutter/widgets.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';

/// Localizes the backend meal-type enum string (e.g. "Breakfast") for display.
String mealTypeLabel(AppLocalizations l10n, String mealType) {
  switch (mealType) {
    case 'Breakfast':
      return l10n.breakfast;
    case 'MidMorning':
      return l10n.midMorning;
    case 'Lunch':
      return l10n.lunch;
    case 'Afternoon':
      return l10n.afternoon;
    case 'Dinner':
      return l10n.dinner;
    case 'PreWorkout':
      return l10n.preWorkout;
    case 'PostWorkout':
      return l10n.postWorkout;
    default:
      return mealType;
  }
}

/// Localizes a trainee goal value (e.g. "Cut", "Bulk", "Maintain", "Recomp").
String goalLabel(AppLocalizations l10n, String goal) {
  switch (goal.toLowerCase()) {
    case 'cut':
      return l10n.goalCut;
    case 'bulk':
      return l10n.goalBulk;
    case 'maintain':
      return l10n.goalMaintain;
    case 'recomp':
      return l10n.goalRecomp;
    default:
      return goal;
  }
}

/// Localizes a food-category value (e.g. "Protein", "Vegetable"). Keeps the
/// English value for the API; this only affects what the user sees.
String foodCategoryLabel(AppLocalizations l10n, String category) {
  switch (category.toLowerCase()) {
    case 'all':
      return l10n.catAll;
    case 'protein':
      return l10n.protein;
    case 'carbs':
      return l10n.carbs;
    case 'fat':
      return l10n.fat;
    case 'vegetable':
      return l10n.catVegetable;
    case 'fruit':
      return l10n.catFruit;
    case 'dairy':
      return l10n.catDairy;
    case 'other':
      return l10n.catOther;
    default:
      return category;
  }
}

const _dayShortEn = [
  'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat',
];
const _dayShortAr = [
  'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت',
];

/// Short, locale-aware day name from a 0=Sunday..6=Saturday index.
String dayShortName(BuildContext context, int dayOfWeek) {
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  if (dayOfWeek < 0 || dayOfWeek > 6) return 'Day $dayOfWeek';
  return isAr ? _dayShortAr[dayOfWeek] : _dayShortEn[dayOfWeek];
}

const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// A compact badge for a day. English uses the 3-letter name (e.g. "Sun");
/// Arabic uses the day's order number (١..٧) because Arabic day names don't
/// abbreviate — showing the full name in the badge AND beside it looked
/// duplicated.
String dayBadge(BuildContext context, int dayOfWeek) {
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  if (dayOfWeek < 0 || dayOfWeek > 6) return '${dayOfWeek + 1}';
  if (!isAr) return _dayShortEn[dayOfWeek];
  return _arabicDigits[dayOfWeek + 1];
}
