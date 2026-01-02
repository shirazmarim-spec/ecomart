import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/color_constants.dart';
import '../constants/translation_constants.dart';
import '../providers/providers.dart';
import 'package:provider/provider.dart';
import 'add_product_screen.dart';
import 'home_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkTheme;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            TranslationConstants.getString(context, 'adminDashboard'),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? ColorConstants.primaryDark
                  : ColorConstants.primaryColor,
            ),
          ),
          backgroundColor: isDark
              ? ColorConstants.backgroundDark
              : ColorConstants.backgroundLight,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                TranslationConstants.getString(context, 'adminWelcome'),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? ColorConstants.primaryDark
                      : ColorConstants.primaryColor,
                ),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProductScreen(),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(
                  TranslationConstants.getString(context, 'addProduct'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? ColorConstants.accentDark
                      : ColorConstants.accentColor,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                ),
                icon: const Icon(Icons.view_list),
                label: Text(
                  TranslationConstants.getString(context, 'viewProducts'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? ColorConstants.primaryDark
                      : ColorConstants.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
