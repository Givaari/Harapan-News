import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:HarapanNews/providers/article_provider.dart';
import 'package:HarapanNews/widgets/news_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch articles when the screen is first built.
    // We use addPostFrameCallback to ensure the context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ArticleProvider>(context, listen: false);
      // Only fetch if the articles list is currently empty to avoid unnecessary loads.
      if (provider.articles.isEmpty) {
        provider.fetchAllArticles();
      }
    });
  }

  /// Function to be called by RefreshIndicator.
  Future<void> _onRefresh() async {
    // Saat refresh, panggil semua fetch untuk sinkronisasi, termasuk bookmark
    await Provider.of<ArticleProvider>(
      context,
      listen: false,
    ).fetchAllArticles();
    await Provider.of<ArticleProvider>(
      context,
      listen: false,
    ).fetchBookmarkedArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use a Row to display logo and title together.
        title: Row(
          children: [
            // Pastikan Anda sudah menambahkan logo.png ke dalam folder assets/images/
            Image.asset('images/logo.png', height: 32, width: 32),
            const SizedBox(width: 12),
            const Text(
              'Harapan News',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: false, // Aligns the title to the left.
      ),
      // Use Consumer to listen for data changes from ArticleProvider.
      body: Consumer<ArticleProvider>(
        builder: (context, articleProvider, child) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: Builder(
              builder: (context) {
                // Show a loading indicator while fetching data.
                if (articleProvider.isLoading &&
                    articleProvider.articles.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Show a message if no news is found.
                if (articleProvider.articles.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada berita saat ini.'),
                  );
                }
                // Build the list of news cards when data is available.
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8.0),
                  itemCount: articleProvider.articles.length,
                  itemBuilder: (context, index) {
                    final news = articleProvider.articles[index];
                    // --- PERBAIKAN DI SINI ---
                    // Menyesuaikan pemanggilan NewsCard dengan parameter baru
                    return NewsCard(
                      news: news,
                      isBookmarked: articleProvider.isBookmarked(news.id),
                      onBookmarkPressed: () {
                        articleProvider.toggleBookmark(news.id);
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
