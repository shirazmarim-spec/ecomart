import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminProvider with ChangeNotifier {
  bool _isAdmin = false;
  final ApiService api = ApiService();

  bool get isAdmin => _isAdmin;

  Future<bool> checkAdmin() async {
    try {
      final user = await api.getUser();
      _isAdmin = user['role'] == 'admin';
      notifyListeners();
      return _isAdmin;
    } catch (e) {
      _isAdmin = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await api.logout();
    _isAdmin = false;
    notifyListeners();
  }
}
