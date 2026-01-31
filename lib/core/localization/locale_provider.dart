import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/injection.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = sl<SharedPreferences>();
    final languageCode = prefs.getString(_localeKey) ?? 'ar';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = sl<SharedPreferences>();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> setArabic() async => await setLocale(const Locale('ar'));
  Future<void> setEnglish() async => await setLocale(const Locale('en'));

  Future<void> toggleLocale() async {
    final newLocale = isArabic ? const Locale('en') : const Locale('ar');
    await setLocale(newLocale);
  }
}