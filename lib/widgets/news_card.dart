import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:HarapanNews/model/news.dart';
import 'package:HarapanNews/providers/auth_provider.dart';
import 'package:HarapanNews/screens/home/article_detail_screen.dart';

class NewsCard extends StatelessWidget {
  final News news;
  // Tambahkan parameter baru untuk status dan aksi bookmark
  final bool isBookmarked;
  final VoidCallback? onBookmarkPressed;

  const NewsCard({
    super.key,
    required this.news,
    // Jadikan parameter baru ini required
    required this.isBookmarked,
    this.onBookmarkPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Dapatkan status login untuk menentukan apakah tombol bookmark ditampilkan
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ArticleDetailScreen(article: news),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          // Gunakan Stack untuk menumpuk tombol di atas gambar
          child: Stack(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.network(
                      news.imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => const SizedBox(
                            width: 120,
                            height: 120,
                            child: Icon(Icons.image_not_supported),
                          ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            news.category.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            news.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'By ${news.author.name}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // --- Tombol Bookmark Ditambahkan Di Sini ---
              if (isLoggedIn && onBookmarkPressed != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color:
                          isBookmarked
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                    ),
                    onPressed: onBookmarkPressed,
                    // Tambahkan latar belakang agar ikon lebih terlihat
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
