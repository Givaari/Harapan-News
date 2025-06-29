import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:HarapanNews/model/user.dart';
import 'package:HarapanNews/providers/auth_provider.dart';
import 'package:HarapanNews/screens/auth/login_screen.dart';
import 'package:HarapanNews/screens/profile/my_articles_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan watch untuk mendapatkan data dan listen: false di dalam event handler
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    // Tampilan jika pengguna tidak login atau data user belum ada
    if (!authProvider.isLoggedIn || user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Silakan login untuk melihat profil Anda.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                ),
                child: const Text('Ke Halaman Login'),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilan utama jika pengguna sudah login
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        children: [
          // --- Bagian Header Profil ---
          _buildProfileHeader(
            user.name,
            user.title ?? 'Jabatan tidak tersedia',
            user.avatar,
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white12),

          // --- Bagian Menu ---
          _buildProfileMenuItem(
            context,
            icon: Icons.article_outlined,
            title: 'Artikel Saya',
            onTap: () {
              // PERBAIKAN: Menambahkan halaman tujuan navigasi
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyArticlesScreen()),
              );
            },
          ),
          _buildProfileMenuItem(
            context,
            icon: Icons.edit_outlined,
            title: 'Atur Profil',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Halaman Edit Profil belum diimplementasikan.'),
                ),
              );
            },
          ),
          const Divider(color: Colors.white12),

          // --- Tombol Logout ---
          const SizedBox(height: 20),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  // Widget untuk header profil
  Widget _buildProfileHeader(String name, String title, String? avatarUrl) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white24,
          child: CircleAvatar(
            radius: 48,
            backgroundColor: Colors.grey[800],
            backgroundImage:
                (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : null,
            // PERBAIKAN "LEMOT": Menambahkan placeholder saat gambar belum dimuat
            child:
                (avatarUrl == null || avatarUrl.isEmpty)
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  // Widget untuk setiap item menu
  Widget _buildProfileMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
    );
  }

  // Widget untuk tombol logout
  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        // Menggunakan context.read karena ini di dalam event, tidak perlu me-listen
        await context.read<AuthProvider>().logout();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text(
        'Logout',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFE94560),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        shadowColor: const Color(0xFFE94560).withOpacity(0.4),
      ),
    );
  }
}
