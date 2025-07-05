import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:HarapanNews/config/api_config.dart';
import 'package:HarapanNews/model/user.dart';

class AuthService {
  /// Fungsi untuk melakukan registrasi pengguna baru.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String title,
    required String avatar,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/register');

    final body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'title': title,
      'avatar': avatar,
    });

    // --- KODE DEBUGGING DIMULAI ---
    print("===================================");
    print("== MEMULAI PROSES REGISTRASI ==");
    print("URL Tujuan: $uri");
    print("Data yang Dikirim (Body): $body");
    print("===================================");
    // --- KODE DEBUGGING SELESAI ---

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // --- KODE DEBUGGING DIMULAI ---
      print("\n== RESPON DARI SERVER ==");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("===================================");
      // --- KODE DEBUGGING SELESAI ---

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        print("INFO: Registrasi terdeteksi berhasil.");
        return {
          'token': responseData['data']['token'],
          'user': User.fromJson(responseData['data']['user']),
        };
      } else {
        print("ERROR: Registrasi gagal menurut server.");
        throw Exception(responseData['message'] ?? 'Registrasi Gagal');
      }
    } catch (e) {
      print("EXCEPTION: Terjadi kesalahan saat proses registrasi: $e");
      rethrow;
    }
  }

  // Fungsi login tidak diubah
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    final body = jsonEncode({'email': email, 'password': password});
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      final data = responseData['data'];
      return {'token': data['token'], 'user': User.fromJson(data['user'])};
    } else {
      throw Exception(responseData['message'] ?? 'Login Gagal');
    }
  }
}
