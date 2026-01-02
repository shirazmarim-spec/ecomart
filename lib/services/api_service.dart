import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000/api";
    } else {
      return "http://10.0.2.2:8000/api";
    }
  }

  final http.Client client = http.Client();

  Future<Map<String, String>> _getHeaders({bool withToken = false}) async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (withToken) {
      final token = await getToken();
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveToken(data['token']);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      await _saveToken(data['token']);
      return data;
    } else {
      throw Exception('Register failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final response = await client.get(
      Uri.parse('$baseUrl/user'),
      headers: await _getHeaders(withToken: true),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Get user failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getProducts() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/products'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Get products failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    await _removeToken();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> sendNotification(String message) async {
    final headers = await _getHeaders(withToken: true);
    final response = await client.post(
      Uri.parse('$baseUrl/notifications/send'),
      headers: headers,
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode != 200) {
      throw Exception('Send notification failed: ${response.body}');
    }
  }

  Future<Map<String, String>> getHeaders({bool withToken = false}) async {
    return await _getHeaders(withToken: withToken);
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> data) async {
    final headers = await _getHeaders(withToken: true);
    final response = await client.put(
      Uri.parse('$baseUrl/user'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Update user failed: ${response.body}');
    }
  }

  Future<List<dynamic>> getOrders() async {
    final headers = await _getHeaders(withToken: true);
    final response = await client.get(
      Uri.parse('$baseUrl/orders'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'] ?? [];
    } else {
      throw Exception('Get orders failed: ${response.body}');
    }
  }

  void dispose() {
    client.close();
  }
}
