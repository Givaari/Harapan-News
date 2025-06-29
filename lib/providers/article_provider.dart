import 'package:flutter/material.dart';
import 'package:HarapanNews/model/news.dart';
import 'package:HarapanNews/services/article_service.dart';

class ArticleProvider with ChangeNotifier {
  final ArticleService _articleService = ArticleService();
  String? _token; // Jadikan token sebagai properti yang bisa diubah

  // --- State untuk Artikel di Halaman Utama ---
  List<News> _articles = [];
  List<News> get articles => _articles;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- State untuk Artikel yang dibuat User ---
  List<News> _myArticles = [];
  List<News> get myArticles => _myArticles;
  bool _isMyArticlesLoading = false;
  bool get isMyArticlesLoading => _isMyArticlesLoading;

  // --- State untuk Bookmark ---
  List<News> _bookmarkedArticles = [];
  List<News> get bookmarkedArticles => _bookmarkedArticles;
  bool _isBookmarksLoading = false;
  bool get isBookmarksLoading => _isBookmarksLoading;

  // Constructor simpel yang langsung mengambil berita publik
  ArticleProvider() {
    fetchAllArticles();
  }

  /// Method ini akan dipanggil oleh Provider di main.dart saat status login berubah.
  void updateToken(String? newToken) {
    // Hanya proses jika tokennya benar-benar berubah
    if (_token != newToken) {
      _token = newToken;
      // Jika user login (token ada), ambil data spesifik user.
      if (_token != null) {
        fetchMyArticles();
        fetchBookmarkedArticles();
      } else {
        // Jika user logout, kosongkan data spesifik user.
        _myArticles = [];
        _bookmarkedArticles = [];
        notifyListeners();
      }
    }
  }

  // === FUNGSI FETCH DATA ===

  Future<void> fetchAllArticles() async {
    _isLoading = true;
    notifyListeners();
    try {
      _articles = await _articleService.getArticles();
    } catch (e) {
      print('Error fetching all articles: $e');
      _articles = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyArticles() async {
    if (_token == null) return;
    _isMyArticlesLoading = true;
    notifyListeners();
    try {
      _myArticles = await _articleService.getUserArticles();
    } catch (e) {
      print('Error fetching my articles: $e');
      _myArticles = [];
    }
    _isMyArticlesLoading = false;
    notifyListeners();
  }

  Future<void> fetchBookmarkedArticles() async {
    if (_token == null) return;
    _isBookmarksLoading = true;
    notifyListeners();
    try {
      _bookmarkedArticles = await _articleService.getBookmarkedArticles();
    } catch (e) {
      print('Error fetching bookmarks: $e');
      _bookmarkedArticles = [];
    }
    _isBookmarksLoading = false;
    notifyListeners();
  }

  // === FUNGSI CRUD & BOOKMARK (Tidak ada perubahan di sini) ===

  Future<void> createArticle(Map<String, dynamic> data) async {
    if (_token == null)
      throw Exception('Anda harus login untuk membuat artikel');
    await _articleService.createArticle(data);
    await fetchMyArticles();
    await fetchAllArticles();
  }

  Future<void> deleteArticle(String id) async {
    if (_token == null)
      throw Exception('Anda harus login untuk menghapus artikel');
    await _articleService.deleteArticle(id);
    await fetchMyArticles();
    await fetchAllArticles();
  }

  bool isBookmarked(String articleId) {
    return _bookmarkedArticles.any((article) => article.id == articleId);
  }

  Future<void> toggleBookmark(String articleId) async {
    if (_token == null) throw Exception('Anda harus login untuk bookmark');
    final currentlyBookmarked = isBookmarked(articleId);
    if (currentlyBookmarked) {
      _bookmarkedArticles.removeWhere((article) => article.id == articleId);
    } else {
      final articleToAdd = _articles.firstWhere(
        (a) => a.id == articleId,
        orElse: () => _myArticles.firstWhere((a) => a.id == articleId),
      );
      _bookmarkedArticles.add(articleToAdd);
    }
    notifyListeners();
    try {
      if (currentlyBookmarked) {
        await _articleService.removeBookmark(articleId);
      } else {
        await _articleService.addBookmark(articleId);
      }
      await fetchBookmarkedArticles();
    } catch (e) {
      print('Error toggling bookmark: $e');
      await fetchBookmarkedArticles();
    }
  }
}
