import 'package:HarapanNews/model/news.dart';

// Kelas ini berfungsi sebagai "bungkus" untuk dua jenis data
class ArticleDetailData {
  final News news;
  final bool isBookmarked;

  ArticleDetailData({required this.news, required this.isBookmarked});
}
