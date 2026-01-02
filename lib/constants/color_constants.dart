import 'package:flutter/material.dart';

class ColorConstants {
  static const Color themeColor = Color(0xFFF8BBD9);
  static const MaterialColor materialThemeColor =
      MaterialColor(0xFFF8BBD9, <int, Color>{
        50: Color.fromRGBO(248, 187, 217, .1),
        100: Color.fromRGBO(248, 187, 217, .2),
        200: Color.fromRGBO(248, 187, 217, .3),
        300: Color.fromRGBO(248, 187, 217, .4),
        400: Color.fromRGBO(248, 187, 217, .5),
        500: Color.fromRGBO(248, 187, 217, .6),
        600: Color.fromRGBO(248, 187, 217, .7),
        700: Color.fromRGBO(248, 187, 217, .8),
        800: Color.fromRGBO(248, 187, 217, .9),
        900: Color.fromRGBO(248, 187, 217, 1),
      });

  static const Color primaryColor = Color(0xFFF5F5DC);
  static const Color accentColor = Color(0xFFFFC1CC);
  static const Color errorColor = Color(0xFFE57373);
  static const Color successColor = Color(0xFFB2DFDB);

  static const Color backgroundLight = Color(0xFFFAF9F6);
  static const Color greyColor = Color(0xFF9E9E9E);
  static const Color greyColor2 = Color(0xFFF5F5F5);

  static const Color backgroundDark = Color(0xFF1E1E1E);
  static const Color primaryDark = Color(0xFFE0E0E0);
  static const Color accentDark = Color(0xFFFF6B9D);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color successDark = Color(0xFF66BB6A);
  static const Color greyDark = Color(0xFF757575);

  static const Color dialogBackground = Color(0xFFF5F5DC);
  static const Color dialogBackgroundDark = Color(0xFF424242);

  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2D2D2D);
  static const Color textDark = Color(0xFFB0B0B0);
}

extension ThemeExtension on ThemeData {
  Color get primary => ColorConstants.primaryColor;
  Color get accent => ColorConstants.accentColor;
  Color get error => ColorConstants.errorColor;
  Color get success => ColorConstants.successColor;
}
