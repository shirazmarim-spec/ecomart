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
    return _items.fold(0.0, (sum, item) {
      final price = double.tryParse(item.product['price'].toString()) ?? 0.0;
      return sum + (price * item.quantity);
    });
  }

  void addItem(dynamic product) {
    final existingIndex = _items.indexWhere(
      (item) => item.product['id'] == product['id'],
    );
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      final parsedProduct = Map<String, dynamic>.from(product);
      parsedProduct['price'] =
          double.tryParse(product['price'].toString()) ?? 0.0;
      _items.add(CartItem(product: parsedProduct));
    }
    notifyListeners();
  }

  void decreaseQuantity(dynamic productId) {
    final existingIndex = _items.indexWhere(
      (item) => item.product['id'] == productId,
    );
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity--;
      } else {
        _items.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

