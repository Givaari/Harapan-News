import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:HarapanNews/providers/article_provider.dart';
import 'package:HarapanNews/providers/auth_provider.dart';
import 'package:HarapanNews/screens/auth/login_screen.dart';
import 'package:HarapanNews/screens/other/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 1. Provider untuk otentikasi
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // 2. Provider untuk artikel, yang "mendengarkan" AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, ArticleProvider>(
          // Buat instance ArticleProvider hanya sekali
          create: (context) => ArticleProvider(),

          // PERBAIKAN UTAMA DI SINI:
          // Menggunakan cascade operator (..) untuk meng-update provider yang ada
          // tanpa membuatnya ulang. Ini adalah pola yang lebih aman.
          update: (context, auth, articleProvider) {
            // 'articleProvider' adalah instance yang sudah ada, kita hanya perlu
            // memanggil method updateToken padanya.
            return articleProvider!..updateToken(auth.token);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harapan News',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1F2937),
        primaryColor: const Color(0xFF3B82F6),
        cardColor: const Color(0xFF374151),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F2937),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      // SplashScreen sekarang menjadi satu-satunya halaman awal
      // yang bertanggung jawab atas navigasi awal.
      home: const SplashScreen(),
      routes: {'/login': (context) => const LoginScreen()},
      debugShowCheckedModeBanner: false,
    );
  }
}
