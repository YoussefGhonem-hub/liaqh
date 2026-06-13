import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_mode';
  ThemeMode _mode = ThemeMode.light;

  ThemeProvider() {
    _load();
  }

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    _mode = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  void toggle() => setMode(isDark ? ThemeMode.light : ThemeMode.dark);
}
