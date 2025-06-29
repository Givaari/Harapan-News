import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:HarapanNews/providers/article_provider.dart';

class CreateArticleScreen extends StatefulWidget {
  const CreateArticleScreen({super.key});

  @override
  State<CreateArticleScreen> createState() => _CreateArticleScreenState();
}

class _CreateArticleScreenState extends State<CreateArticleScreen> {
  // Global key to validate the form
  final _formKey = GlobalKey<FormState>();

  // Controllers for each text field
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // State variables
  String _selectedCategory = 'Technology'; // Default category
  bool _isLoading = false;

  final List<String> _categories = [
    "Technology",
    "Business",
    "Politics",
    "Sports",
    "Health",
    "Entertainment",
    "World",
  ];

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  /// Handles the article submission process
  Future<void> _submitArticle() async {
    // Validate the form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Prepare data to be sent to the provider
    final articleData = {
      "title": _titleController.text.trim(),
      "content": _contentController.text.trim(),
      "category": _selectedCategory,
      "imageUrl": _imageUrlController.text.trim(),
      "readTime": "5 min", // Default value
      "isTrending": false, // Default value
      "tags": [_selectedCategory.toLowerCase(), "new"], // Default tags
    };

    // Get the provider instance
    final articleProvider = Provider.of<ArticleProvider>(
      context,
      listen: false,
    );

    try {
      // Call the createArticle method from the provider
      await articleProvider.createArticle(articleData);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artikel berhasil dipublikasikan!'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop the screen and return 'true' to indicate success
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tulis Artikel Baru'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              _buildTextFormField(
                controller: _titleController,
                labelText: 'Judul Artikel',
                hintText: 'Masukkan judul yang menarik',
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Judul tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 20),

              // Content Field
              _buildTextFormField(
                controller: _contentController,
                labelText: 'Konten',
                hintText: 'Tulis isi artikel Anda di sini...',
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konten tidak boleh kosong';
                  }
                  if (value.length < 50) {
                    return 'Konten minimal harus 50 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Image URL Field
              _buildTextFormField(
                controller: _imageUrlController,
                labelText: 'URL Gambar Sampul',
                hintText: 'https://contoh.com/gambar.jpg',
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'URL Gambar tidak boleh kosong';
                  }
                  // PERBAIKAN DI SINI: Logika validasi URL yang lebih baik
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.isAbsolute) {
                    return 'Masukkan URL yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              _buildCategoryDropdown(),
              const SizedBox(height: 40),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget for building a consistent TextFormField
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white38),
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          // Tambahkan ini untuk konsistensi
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          // Tambahkan ini untuk konsistensi
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  /// Helper widget for building the category dropdown
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items:
          _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _selectedCategory = newValue;
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Kategori',
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
      ),
    );
  }

  /// Helper widget for building the submit button
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitArticle,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFFE94560),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      child:
          _isLoading
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
              : const Text(
                'PUBLIKASIKAN ARTIKEL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
    );
  }
}
