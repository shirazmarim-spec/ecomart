import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart'; // import الservice

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> products = [];
  bool isLoading = true;
  final ApiService api = ApiService();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final data = await api.getProducts();
      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ecomart - Products'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? Center(child: Text('No products found'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: ListTile(
                    leading: product['image_url'] != null
                        ? Image.network(
                            product['image_url'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.image_not_supported),
                    title: Text(product['name']),
                    subtitle: Text(
                      '\$${product['price']} - Stock: ${product['stock']}',
                    ),
                    trailing: Icon(Icons.add_shopping_cart),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${product['name']} to cart!'),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    api.dispose();
    super.dispose();
  }
}
