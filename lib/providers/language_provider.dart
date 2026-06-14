import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  static const _prefKey = 'app_locale';
  static const _chosenKey = 'app_locale_chosen';

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  /// Whether the user has explicitly picked a language at least once.
  bool _chosen = false;
  bool get hasChosenLanguage => _chosen;

  LanguageProvider() {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey) ?? 'en';
    _locale = Locale(code);
    _chosen = prefs.getBool(_chosenKey) ?? false;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale, {bool markChosen = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (markChosen && !_chosen) {
      _chosen = true;
      await prefs.setBool(_chosenKey, true);
    }
    if (_locale == locale) {
      if (markChosen) notifyListeners();
      return;
    }
    _locale = locale;
    await prefs.setString(_prefKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    await setLocale(isArabic ? const Locale('en') : const Locale('ar'));
  }
}
