import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/color_constants.dart';
import '../constants/translation_constants.dart';
import '../providers/providers.dart';
import 'package:provider/provider.dart';
import '../screens/order_details_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrdersProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkTheme;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final ordersProvider = Provider.of<OrdersProvider>(context);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            TranslationConstants.getString(context, 'orders'),
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
        body: RefreshIndicator(
          onRefresh: () => ordersProvider.fetchOrders(),
          child: ordersProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ordersProvider.orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        size: 64,
                        color: isDark
                            ? ColorConstants.greyDark
                            : ColorConstants.greyColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        TranslationConstants.getString(context, 'noOrders'),
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
              : ListView.builder(
                  itemCount: ordersProvider.orders.length,
                  itemBuilder: (context, index) {
                    final order = ordersProvider.orders[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          'Order #${order.id}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? ColorConstants.primaryDark
                                : ColorConstants.primaryColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total: \$${order.total.toStringAsFixed(2)}'),
                            Text('Status: ${order.status}'),
                            Text(
                              'Date: ${order.createdAt.toString().substring(0, 10)}',
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.receipt,
                          color: isDark
                              ? ColorConstants.accentDark
                              : ColorConstants.accentColor,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailsScreen(order: order),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
