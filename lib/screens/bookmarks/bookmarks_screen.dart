import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:HarapanNews/providers/article_provider.dart';
import 'package:HarapanNews/providers/auth_provider.dart';
import 'package:HarapanNews/screens/auth/login_screen.dart';
import 'package:HarapanNews/widgets/news_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch bookmarks when the screen is first loaded, if not already loading.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ArticleProvider>(context, listen: false);
      if (!provider.isBookmarksLoading) {
        provider.fetchBookmarkedArticles();
      }
    });
  }

  Future<void> _onRefresh() async {
    await Provider.of<ArticleProvider>(
      context,
      listen: false,
    ).fetchBookmarkedArticles();
  }

  @override
  Widget build(BuildContext context) {
    // Check login status first
    final authProvider = context.watch<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      return _buildLoginPrompt(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Artikel Tersimpan')),
      body: Consumer<ArticleProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: Builder(
              builder: (context) {
                if (provider.isBookmarksLoading &&
                    provider.bookmarkedArticles.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.bookmarkedArticles.isEmpty) {
                  return _buildEmptyState();
                }
                final articles = provider.bookmarkedArticles;
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8.0),
                  itemCount: articles.length,
                  itemBuilder:
                      (context, index) => NewsCard(
                        news: articles[index],
                        // Logic to remove bookmark directly from this screen
                        onBookmarkPressed:
                            () => provider.toggleBookmark(articles[index].id),
                        isBookmarked: true, // All articles here are bookmarked
                      ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Helper widget for empty state
  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: const Center(
              child: Text("Anda belum menyimpan artikel apapun."),
            ),
          ),
        );
      },
    );
  }

  // Helper widget for login prompt
  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artikel Tersimpan')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login untuk melihat artikel yang Anda simpan.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  ),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
