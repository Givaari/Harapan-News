import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:HarapanNews/model/news.dart';
import 'package:HarapanNews/providers/article_provider.dart';
import 'package:HarapanNews/providers/auth_provider.dart';

// Asumsi article_detail_data dan news_service tidak diperlukan lagi karena data via provider
// import 'package:HarapanNews/model/article_detail_data.dart';
// import 'package:HarapanNews/services/article_service.dart';

class ArticleDetailScreen extends StatelessWidget {
  final News article;
  const ArticleDetailScreen({super.key, required this.article});

  void _toggleBookmark(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = Provider.of<ArticleProvider>(context, listen: false);
    final isCurrentlyBookmarked = provider.isBookmarked(article.id);

    try {
      await provider.toggleBookmark(article.id);
      // Notifikasi Bookmark Berhasil
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isCurrentlyBookmarked ? 'Bookmark dihapus' : 'Artikel disimpan',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Notifikasi Bookmark Gagal
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAuthor = authProvider.user?.id == article.author.id;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                article.title,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Image.network(
                article.imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
            actions: [
              // Gunakan Consumer untuk listen perubahan status bookmark
              if (authProvider.isLoggedIn)
                Consumer<ArticleProvider>(
                  builder: (context, provider, child) {
                    final isBookmarked = provider.isBookmarked(article.id);
                    return IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      onPressed: () => _toggleBookmark(context),
                    );
                  },
                ),
              if (isAuthor)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    // TODO: Implement delete logic
                  },
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "By ${article.author.name} • ${article.category}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Divider(height: 32),
                  Text(
                    article.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
