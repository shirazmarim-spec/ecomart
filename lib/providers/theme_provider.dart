import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/color_constants.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false;
  late SharedPreferences prefs;

  ThemeProvider() {
    loadTheme();
    _setInitialSystemTheme();
  }

  bool get isDarkTheme => _isDarkTheme;

  ThemeData get themeData {
    if (_isDarkTheme) {
      return ThemeData.dark().copyWith(
        primaryColor: ColorConstants.primaryDark,
        scaffoldBackgroundColor: ColorConstants.backgroundDark,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.accentDark,
          ),
        ),
      );
    } else {
      return ThemeData.light().copyWith(
        primaryColor: ColorConstants.primaryColor,
        scaffoldBackgroundColor: ColorConstants.backgroundLight,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.accentColor,
          ),
        ),
      );
    }
  }

  Future<void> loadTheme() async {
    prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    notifyListeners();
  }

  void setSystemTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    _isDarkTheme = brightness == Brightness.dark;
    notifyListeners();
  }

  void _setInitialSystemTheme() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isDarkTheme = brightness == Brightness.dark;
    notifyListeners();
  }
}
