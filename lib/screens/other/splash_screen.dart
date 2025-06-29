import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:HarapanNews/providers/auth_provider.dart';
import 'package:HarapanNews/screens/main_screen.dart';
import 'package:HarapanNews/screens/other/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the timer when the widget is first built.
    // After 5 seconds, the _checkAuthAndNavigate function will be called.
    Timer(const Duration(seconds: 5), _checkAuthAndNavigate);
  }

  /// Checks the user's login status and navigates to the appropriate screen.
  void _checkAuthAndNavigate() {
    // Ensure the widget is still in the widget tree before navigating.
    if (!mounted) return;

    // Get the AuthProvider to check the login state.
    // 'listen: false' is used because we are in a method, not the build function.
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Navigate based on whether the user is logged in.
    if (authProvider.isLoggedIn) {
      // If logged in, go to MainScreen.
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      // If not logged in, go to OnboardingScreen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a consistent background color from your theme.
      backgroundColor: const Color(0xFF1F2937),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the logo from the assets folder.
            Image.asset(
              'images/logo.png',
              width: 165, // Adjust size as needed.
              height: 165,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Harapan News',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
