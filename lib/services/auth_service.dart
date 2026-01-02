import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = "http://10.11.241.51:8000/auth";
  final storage = const FlutterSecureStorage();

  // 1. LOGIN (POST /jwt/create/)
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/jwt/create/'),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access', value: data['access']);
      await storage.write(key: 'refresh', value: data['refresh']);
      return true;
    }
    return false;
  }

  // 2. REGISTER (POST /users/)
  Future<bool> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/'),
      body: {
        'username': username,
        'email': email,
        'password': password,
        're_password': password, // Djoser usually requires confirmation
      },
    );
    return response.statusCode == 201;
  }

  // 3. GET CURRENT USER (GET /users/me/)
  Future<Map<String, dynamic>?> getMe() async {
    String? token = await storage.read(key: 'access');
    final response = await http.get(
      Uri.parse('$baseUrl/users/me/'),
      headers: {'Authorization': 'JWT $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // 4. LOGOUT
  Future<void> logout() async {
    await storage.deleteAll();
  }
}
