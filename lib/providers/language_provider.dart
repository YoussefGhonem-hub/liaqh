import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  static const _prefKey = 'app_locale';

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  LanguageProvider() {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey) ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    await setLocale(isArabic ? const Locale('en') : const Locale('ar'));
  }
}
