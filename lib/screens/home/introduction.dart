import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:HarapanNews/providers/article_provider.dart';
import 'package:HarapanNews/providers/auth_provider.dart';
import 'package:HarapanNews/screens/auth/login_screen.dart';
import 'package:HarapanNews/screens/other/profile_screen.dart';
import 'package:HarapanNews/widgets/news_card.dart';
import 'package:HarapanNews/screens/article/create_article_screen.dart';

// CATATAN: File ini memiliki fungsionalitas yang sangat mirip dengan home_screen.dart.
// Pertimbangkan untuk menghapus file ini untuk menyederhanakan proyek.

class IntroductionScreenBody extends StatefulWidget {
  const IntroductionScreenBody({super.key});

  @override
  State<IntroductionScreenBody> createState() => _IntroductionScreenBodyState();
}

class _IntroductionScreenBodyState extends State<IntroductionScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ArticleProvider>(context, listen: false);
      if (provider.articles.isEmpty) {
        provider.fetchAllArticles();
      }
    });
  }

  Future<void> _onRefresh() async {
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
        title: const Text("Beranda"),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return IconButton(
                onPressed: () {
                  if (auth.isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                icon: Icon(auth.isLoggedIn ? Icons.person : Icons.login),
              );
            },
          ),
        ],
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, articleProvider, child) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: Builder(
              builder: (context) {
                if (articleProvider.isLoading &&
                    articleProvider.articles.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (articleProvider.articles.isEmpty) {
                  return const Center(
                    child: Text("Tidak ada berita ditemukan."),
                  );
                }

                final articles = articleProvider.articles;
                return ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final news = articles[index];
                    // --- PERBAIKAN DI SINI ---
                    // Menyesuaikan pemanggilan NewsCard dengan parameter baru
                    return NewsCard(
                      news: news,
                      isBookmarked: articleProvider.isBookmarked(news.id),
                      onBookmarkPressed:
                          () => articleProvider.toggleBookmark(news.id),
                    );
                  },
                );
              },
            ),
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
