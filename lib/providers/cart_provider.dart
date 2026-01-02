import 'package:flutter/material.dart';

class CartItem {
  final dynamic product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  // ignore: prefer_final_fields
  List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  double get totalAmount {
    return _items.fold(
      0.0,
      (sum, item) => sum + (item.product['price'] * item.quantity),
    );
  }

  void addItem(dynamic product) {
    final existingIndex = _items.indexWhere(
      (item) => item.product['id'] == product['id'],
    );
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeItem(dynamic productId) {
    _items.removeWhere((item) => item.product['id'] == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
