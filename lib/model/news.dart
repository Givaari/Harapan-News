class News {
  final String id;
  final String title;
  final String category;
  final String? publishedAt;
  final String? readTime;
  final String imageUrl;
  final String content;
  final Author author;

  News({
    required this.id,
    required this.title,
    required this.category,
    this.publishedAt,
    this.readTime,
    required this.imageUrl,
    required this.content,
    required this.author,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      // Memberikan nilai default '' (string kosong) jika data dari API null
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'No Title',
      category: json['category'] as String? ?? 'Uncategorized',
      publishedAt: json['publishedAt'] as String?,
      readTime: json['readTime'] as String?,
      imageUrl: json['imageUrl'] as String? ?? 'https://via.placeholder.com/150',
      content: json['content'] as String? ?? 'No content available.',
      // Memeriksa jika 'author' null, maka buat Author default
      author: json['author'] != null
          ? Author.fromJson(json['author'] as Map<String, dynamic>)
          : Author.defaultAuthor(), // Menggunakan factory method default
    );
  }
}

class Author {
  final String id;
  final String name;
  final String? title;
  final String? avatar;

  Author({
    required this.id, 
    required this.name, 
    this.title, 
    this.avatar
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      // Memberikan nilai default jika data dari API null
      id: json['id'] as String? ?? 'unknown_id',
      name: json['name'] as String? ?? 'Unknown Author',
      title: json['title'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  // Factory method untuk membuat author default jika data tidak ada
  factory Author.defaultAuthor() {
    return Author(
      id: 'unknown_id',
      name: 'Unknown Author',
      title: 'Contributor',
      avatar: null,
    );
  }
}