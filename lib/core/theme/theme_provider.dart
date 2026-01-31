import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/injection.dart';
import '../constants/app_colors.dart';

enum ThemeModeType { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeModeType _themeModeType = ThemeModeType.system;

  ThemeModeType get themeModeType => _themeModeType;

  ThemeMode get themeMode {
    switch (_themeModeType) {
      case ThemeModeType.light:
        return ThemeMode.light;
      case ThemeModeType.dark:
        return ThemeMode.dark;
      case ThemeModeType.system:
        return ThemeMode.system;
    }
  }

  bool get isSystem => _themeModeType == ThemeModeType.system;
  bool get isLight => _themeModeType == ThemeModeType.light;
  bool get isDark => _themeModeType == ThemeModeType.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = sl<SharedPreferences>();
    final index = prefs.getInt(_themeKey) ?? 0;
    _themeModeType = ThemeModeType.values[index];
    notifyListeners();
  }

  Future<void> setTheme(ThemeModeType mode) async {
    if (_themeModeType == mode) return;
    _themeModeType = mode;
    final prefs = sl<SharedPreferences>();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setLight() async => await setTheme(ThemeModeType.light);
  Future<void> setDark() async => await setTheme(ThemeModeType.dark);
  Future<void> setSystem() async => await setTheme(ThemeModeType.system);

  Future<void> toggleTheme() async {
    if (_themeModeType == ThemeModeType.dark) {
      await setLight();
    } else {
      await setDark();
    }
  }

  // ✅ تحديث System UI - مبسط
  void updateSystemUI(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDarkMode ? AppColors.backgroundDark : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }
}