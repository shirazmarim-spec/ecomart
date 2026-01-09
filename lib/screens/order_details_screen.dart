import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/color_constants.dart';
import '../constants/translation_constants.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../models/order.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkTheme;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${TranslationConstants.getString(context, 'order')} #${order.id}',
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              isArabic
                  ? 'assets/images/united-arab-emirates.png'
                  : 'assets/images/united-states-of-america.png',
              width: 24,
              height: 24,
            ),
            onPressed: () => localeProvider.toggleLocale(),
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark
                  ? ColorConstants.accentDark
                  : ColorConstants.accentColor,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      backgroundColor: isDark
          ? ColorConstants.backgroundDark
          : ColorConstants.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: isDark
                  ? ColorConstants.cardDark
                  : ColorConstants.cardLight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${TranslationConstants.getString(context, 'status')}: ${order.status.toUpperCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: order.status == 'pending'
                            ? Colors.orange
                            : order.status == 'completed'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${TranslationConstants.getString(context, 'date')}: ${order.createdAt.toString().substring(0, 10)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? ColorConstants.textDark : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${TranslationConstants.getString(context, 'total')}: \$${order.total.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? ColorConstants.primaryDark
                            : ColorConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${TranslationConstants.getString(context, 'items')} (${order.products.length})',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? ColorConstants.primaryDark
                    : ColorConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: order.products.length,
                itemBuilder: (context, index) {
                  final product = order.products[index];
                  final double price = double.parse(
                    product['price'].toString(),
                  );
                  return Card(
                    color: isDark
                        ? ColorConstants.cardDark
                        : ColorConstants.cardLight,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isDark
                            ? ColorConstants.accentDark
                            : ColorConstants.accentColor,
                        child: Text(
                          '${product['quantity']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(
                        product['name'] ?? 'Product ${product['id']}',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      subtitle: Text(
                        '${TranslationConstants.getString(context, 'priceEach')}: \$${price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? ColorConstants.textDark : Colors.grey,
                        ),
                      ),
                      trailing: Text(
                        '${TranslationConstants.getString(context, 'quantity')}: ${product['quantity']}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? ColorConstants.primaryDark
                              : ColorConstants.primaryColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? ColorConstants.accentDark
                      : ColorConstants.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        TranslationConstants.getString(context, 'reOrderAdded'),
                      ),
                    ),
                  );
                },
                child: Text(
                  TranslationConstants.getString(context, 'reOrder'),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

