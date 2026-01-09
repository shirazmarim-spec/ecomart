import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/color_constants.dart';
import '../constants/translation_constants.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../services/api_service.dart';
import '../screens/payment_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isCreatingOrder = false;
  String? _errorMessage;

  Future<void> _createOrderAndProceedToPayment() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final api = ApiService();

    if (cartProvider.itemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TranslationConstants.getString(context, 'emptyCart')),
        ),
      );
      return;
    }

    setState(() {
      _isCreatingOrder = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/orders'),
        headers: await api.getHeaders(withToken: true),
        body: jsonEncode({
          'products': cartProvider.items.map((item) {
            return {
              'id': item.product['id'],
              'quantity': item.quantity,
              'price': item.product['price'],
              'name': item.product['name'],
              'image_url': item.product['image_url'],
            };
          }).toList(),
          'total': cartProvider.totalAmount,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final int orderId = responseData['data']['id'];

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              total: cartProvider.totalAmount,
              orderId: orderId,
            ),
          ),
        );
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${TranslationConstants.getString(context, 'orderCreationFailed')}: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkTheme;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            TranslationConstants.getString(context, 'cart'),
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
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (cartProvider.itemCount == 0) ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: isDark
                              ? ColorConstants.greyDark
                              : ColorConstants.greyColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          TranslationConstants.getString(context, 'emptyCart'),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: isDark
                                ? ColorConstants.primaryDark
                                : ColorConstants.greyColor,
                          ),
                          textAlign: isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            TranslationConstants.getString(
                              context,
                              'continueShopping',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.itemCount,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            item.product['image_url'] ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image_not_supported, size: 40),
                          ),
                          title: Text(
                            item.product['name'] ?? 'Unknown Product',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '\$${item.product['price']} x ${item.quantity}',
                            style: GoogleFonts.poppins(color: Colors.grey[600]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline),
                                onPressed: () => cartProvider.decreaseQuantity(
                                  item.product['id'],
                                ),
                              ),
                              Text(
                                '${item.quantity}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline),
                                onPressed: () =>
                                    cartProvider.addItem(item.product),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? ColorConstants.backgroundDark
                        : ColorConstants.backgroundLight,
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? ColorConstants.greyDark
                            : ColorConstants.greyColor2,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            TranslationConstants.getString(context, 'total'),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? ColorConstants.primaryDark
                                  : ColorConstants.primaryColor,
                            ),
                          ),
                          Text(
                            '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? ColorConstants.accentDark
                                  : ColorConstants.accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isCreatingOrder
                              ? null
                              : _createOrderAndProceedToPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? ColorConstants.accentDark
                                : ColorConstants.accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isCreatingOrder
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  TranslationConstants.getString(
                                    context,
                                    'checkout',
                                  ),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
