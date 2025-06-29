import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:HarapanNews/providers/article_provider.dart';
import 'package:HarapanNews/screens/article/create_article_screen.dart';
import 'package:HarapanNews/widgets/news_card.dart';

class MyArticlesScreen extends StatefulWidget {
  const MyArticlesScreen({super.key});

  @override
  State<MyArticlesScreen> createState() => _MyArticlesScreenState();
}

class _MyArticlesScreenState extends State<MyArticlesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArticleProvider>(context, listen: false).fetchMyArticles();
    });
  }

  Future<void> _deleteArticle(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Artikel?'),
            content: const Text('Tindakan ini tidak dapat diurungkan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      await Provider.of<ArticleProvider>(
        context,
        listen: false,
      ).deleteArticle(id);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Artikel berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus artikel: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artikel Saya')),
      body: Consumer<ArticleProvider>(
        builder: (context, provider, child) {
          if (provider.isMyArticlesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.myArticles.isEmpty) {
            return const Center(child: Text('Anda belum menulis artikel.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0),
            itemCount: provider.myArticles.length,
            itemBuilder: (context, index) {
              final article = provider.myArticles[index];
              return Dismissible(
                key: Key(article.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _deleteArticle(article.id),
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                // --- PERBAIKAN DI SINI ---
                // Menambahkan parameter yang dibutuhkan oleh NewsCard.
                child: NewsCard(
                  news: article,
                  isBookmarked: provider.isBookmarked(article.id),
                  onBookmarkPressed: () => provider.toggleBookmark(article.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateArticleScreen()),
          );
          if (result == true && mounted) {
            Provider.of<ArticleProvider>(
              context,
              listen: false,
            ).fetchMyArticles();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
