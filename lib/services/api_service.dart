import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // للـ token

class ApiService {
  static const String baseUrl =
      "http://10.0.2.2:8000/api/"; // للـ emulator (localhost:8000 من الجهاز)

  final http.Client client = http.Client();

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'token',
        data['token'],
      ); // حفظ token مثل TokenProvider
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Register
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      return data;
    } else {
      throw Exception('Register failed: ${response.body}');
    }
  }

  // Get User (مع token)
  Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await client.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Get user failed: ${response.body}');
    }
  }

  // Get Products
  Future<List<dynamic>> getProducts() async {
    final response = await client.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Get products failed: ${response.body}');
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  void dispose() {
    client.close();
  }
}
