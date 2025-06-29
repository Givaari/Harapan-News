import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'https://rest-api-berita.vercel.app/api/v1';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.http(_baseUrl, '/api/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['body']['success'] == true) {
        return data['body']['data'];
      } else {
        throw Exception(data['body']['message'] ?? 'Login failed');
      }
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }
}