import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:HarapanNews/config/api_config.dart';
import 'package:HarapanNews/model/article_detail_data.dart';
import 'package:HarapanNews/model/news.dart';
import 'package:HarapanNews/services/secure_storage_service.dart';

class ArticleService {
  final SecureStorageService _storageService = SecureStorageService();

  Future<Map<String, String>> _getHeaders({
    bool needsAuth = false,
    bool hasBody = false,
  }) async {
    final headers = <String, String>{};
    if (hasBody) {
      headers['Content-Type'] = 'application/json';
    }
    if (needsAuth) {
      final token = await _storageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // --- Fungsi-fungsi di bawah ini yang akan diperbaiki ---

  Future<List<News>> getArticles({int page = 1, int limit = 10}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/news?page=$page&limit=$limit');
    final response = await http.get(uri, headers: await _getHeaders());
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      // Path ini sudah benar, kita akan tiru untuk fungsi lainnya
      final List articlesJson = responseData['data']['articles'];
      return articlesJson.map((json) => News.fromJson(json)).toList();
    } else {
      throw Exception(responseData['message'] ?? 'Gagal memuat artikel');
    }
  }

  Future<List<News>> getUserArticles() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/news/user/me');
    final response = await http.get(
      uri,
      headers: await _getHeaders(needsAuth: true),
    );
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      // PERBAIKAN: Mengambil list dari dalam object 'data'
      final List articlesJson = responseData['data']['articles'];
      return articlesJson.map((json) => News.fromJson(json)).toList();
    } else {
      throw Exception(responseData['message'] ?? 'Gagal memuat artikel Anda');
    }
  }

  Future<List<News>> getBookmarkedArticles() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/news/bookmarks/list');
    final response = await http.get(
      uri,
      headers: await _getHeaders(needsAuth: true),
    );
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      // PERBAIKAN: Mengambil list dari dalam object 'data'
      final List articlesJson = responseData['data']['articles'];
      return articlesJson.map((json) => News.fromJson(json)).toList();
    } else {
      throw Exception(responseData['message'] ?? 'Gagal memuat bookmark');
    }
  }

  // --- Sisa fungsi tidak perlu diubah ---

  Future<ArticleDetailData> getArticleDetails(
    String articleId,
    bool isLoggedIn,
  ) async {
    try {
      final news = await getArticleById(articleId);
      bool isBookmarked = false;
      if (isLoggedIn) {
        isBookmarked = await checkBookmarkStatus(articleId);
      }
      return ArticleDetailData(news: news, isBookmarked: isBookmarked);
    } catch (e) {
      throw Exception('Gagal memuat detail artikel: $e');
    }
  }

  Future<News> getArticleById(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/news/$id');
    final response = await http.get(uri, headers: await _getHeaders());
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      return News.fromJson(responseData['data']);
    } else {
      throw Exception(responseData['message'] ?? 'Gagal memuat detail artikel');
    }
  }

  Future<void> createArticle(Map<String, dynamic> data) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/news');
    final response = await http.post(
      uri,
      headers: await _getHeaders(needsAuth: true, hasBody: true),
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Gagal membuat artikel');
    }
  }

  Future<News> updateArticle(String id, Map<String, dynamic> data) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/news/$id');
    final response = await http.put(
      uri,
      headers: await _getHeaders(needsAuth: true, hasBody: true),
      body: jsonEncode(data),
    );
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      return News.fromJson(responseData['data']);
    } else {
      throw Exception(responseData['message'] ?? 'Gagal memperbarui artikel');
    }
  }

  Future<void> deleteArticle(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/news/$id');
    final response = await http.delete(
      uri,
      headers: await _getHeaders(needsAuth: true),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus artikel');
    }
  }

  Future<bool> checkBookmarkStatus(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/news/$id/bookmark');
    final response = await http.get(
      uri,
      headers: await _getHeaders(needsAuth: true),
    );
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      return responseData['data']['isSaved'] as bool;
    } else {
      return false;
    }
  }

  Future<void> addBookmark(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/news/$id/bookmark');
    final response = await http.post(
      uri,
      headers: await _getHeaders(needsAuth: true),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menambah bookmark');
    }
  }

  Future<void> removeBookmark(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/news/$id/bookmark');
    final response = await http.delete(
      uri,
      headers: await _getHeaders(needsAuth: true),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus bookmark');
    }
  }
}
