import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:HarapanNews/providers/article_provider.dart'; // Import provider
import 'package:HarapanNews/screens/article/create_article_screen.dart';

class MyArticlesScreen extends StatefulWidget {
  const MyArticlesScreen({super.key});

  @override
  State<MyArticlesScreen> createState() => _MyArticlesScreenState();
}

class _MyArticlesScreenState extends State<MyArticlesScreen> {
  // Panggil fetchMyArticles saat halaman pertama kali dibuka
  @override
  void initState() {
    super.initState();
    // Gunakan addPostFrameCallback agar context tersedia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArticleProvider>(context, listen: false).fetchMyArticles();
    });
  }

  // Fungsi hapus sekarang memanggil provider
  Future<void> _deleteArticle(String id) async {
    try {
      await Provider.of<ArticleProvider>(
        context,
        listen: false,
      ).deleteArticle(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artikel berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            itemCount: provider.myArticles.length,
            itemBuilder: (context, index) {
              final article = provider.myArticles[index];
              return ListTile(
                title: Text(article.title),
                subtitle: Text(article.category),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteArticle(article.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateArticleScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
