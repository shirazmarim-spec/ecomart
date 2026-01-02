import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> toggleLocale() async {
    _locale = _locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', _locale.languageCode);
    notifyListeners();
  }

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('locale') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }
}
