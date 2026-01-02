import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/order.dart';

class OrdersProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  final ApiService api = ApiService();
  final logger = Logger();
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await api.getOrders();
      logger.i('Fetched orders: $data');
      _orders = data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      logger.e('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
