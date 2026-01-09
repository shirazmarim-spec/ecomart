import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../constants/color_constants.dart';
import '../constants/translation_constants.dart';
import '../providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'order_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  Map<String, List<dynamic>> groupedProducts = {};
  bool isLoading = true;
  final ApiService api = ApiService();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    api.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    try {
      final data = await api.getProducts();
      if (mounted) {
        setState(() {
          products = data['data'] ?? [];
          _groupAndFilterProducts('');
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${TranslationConstants.getString(context, 'error')}: $e',
            ),
          ),
        );
      }
    }
  }

  void _groupAndFilterProducts(String query) {
    // فلترة أولاً
    final lowerQuery = query.toLowerCase();
    final tempProducts = query.isEmpty
        ? products
        : products.where((product) {
            final name = (product['name'] ?? '').toLowerCase();
            return name.contains(lowerQuery);
          }).toList();

    // تجميع حسب الفئة
    final Map<String, List<dynamic>> grouped = {};
    for (var product in tempProducts) {
      final categoryName = product['category']?['name'] ?? 'Uncategorized';
      grouped.putIfAbsent(categoryName, () => []);
      grouped[categoryName]!.add(product);
    }

    setState(() {
      groupedProducts = grouped;
      filteredProducts = tempProducts;
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _groupAndFilterProducts(query);
    });
  }

  Future<void> _sendNotification() async {
    try {
      final apiService = ApiService();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/notifications/send'),
        headers: await apiService.getHeaders(withToken: true),
        body: jsonEncode({
          'message': 'Hello from Ecomart app! 🛒 Test notification.',
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent to Telegram!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _openTelegramBot() async {
    final uri = Uri.parse('https://t.me/myecomart_bot');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open Telegram bot')));
      }
    }
  }

  PreferredSizeWidget _buildSearchBar(
    BuildContext context,
    bool isDark,
    bool isArabic,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: TranslationConstants.getString(context, 'search'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDark
                  ? ColorConstants.primaryDark
                  : ColorConstants.greyColor,
            ),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: isDark
                          ? ColorConstants.primaryDark
                          : ColorConstants.greyColor,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  ),
          ),
          onChanged: _onSearchChanged,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkTheme;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ecomart - ${TranslationConstants.getString(context, 'products')}',
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
        bottom: _buildSearchBar(context, isDark, isArabic),
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
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    tooltip: TranslationConstants.getString(context, 'cart'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt),
            tooltip: TranslationConstants.getString(context, 'orders'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderScreen()),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.person),
            tooltip: TranslationConstants.getString(context, 'profile'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchProducts,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : groupedProducts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: isDark
                          ? ColorConstants.primaryDark
                          : ColorConstants.greyColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      TranslationConstants.getString(context, 'noProducts'),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: isDark
                            ? ColorConstants.primaryDark
                            : ColorConstants.greyColor,
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                children: groupedProducts.keys.map((categoryName) {
                  final categoryProducts = groupedProducts[categoryName]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          categoryName,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? ColorConstants.primaryDark
                                : ColorConstants.primaryColor,
                          ),
                        ),
                      ),
                      ...categoryProducts.map(
                        (product) => _ProductCard(
                          product: product,
                          isDark: isDark,
                          isArabic: isArabic,
                          onTap: () {
                            Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).addItem(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${TranslationConstants.getString(context, 'addedToCart')}: ${product['name']}',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'send_notification',
            onPressed: _sendNotification,
            backgroundColor: isDark
                ? ColorConstants.accentDark
                : ColorConstants.accentColor,
            tooltip: TranslationConstants.getString(
              context,
              'sendNotification',
            ),
            child: const Icon(Icons.message),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'open_telegram',
            onPressed: _openTelegramBot,
            backgroundColor: isDark
                ? ColorConstants.primaryDark
                : ColorConstants.primaryColor,
            tooltip: TranslationConstants.getString(context, 'openTelegramBot'),
            child: const Icon(Icons.telegram),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic product;
  final bool isDark;
  final bool isArabic;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.isDark,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final price = product['price'] ?? 0.0;
    final stock = product['stock'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      color: isDark
          ? ColorConstants.backgroundDark
          : ColorConstants.backgroundLight,
      child: ListTile(
        leading: product['image_url'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product['image_url'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_not_supported,
                    color: isDark
                        ? ColorConstants.primaryDark
                        : ColorConstants.greyColor,
                  ),
                ),
              )
            : Icon(
                Icons.image_not_supported,
                color: isDark
                    ? ColorConstants.primaryDark
                    : ColorConstants.greyColor,
              ),
        title: Text(
          product['name'] ?? 'Unknown Product',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark
                ? ColorConstants.primaryDark
                : ColorConstants.primaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TranslationConstants.getPriceStock(price, stock, isArabic),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark
                    ? ColorConstants.greyDark
                    : ColorConstants.greyColor,
              ),
            ),
            if (product['description'] != null &&
                product['description'].toString().isNotEmpty)
              Text(
                product['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.add_shopping_cart,
          color: isDark
              ? ColorConstants.accentDark
              : ColorConstants.accentColor,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

