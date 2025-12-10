import 'package:flutter/material.dart';

/// Splash screen - shown while checking authentication
///
/// WHY: Better UX than blank screen
/// - Shows branding/logo
/// - Gives time for auth check
/// - Smooth transition to login/home
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your app logo
            Icon(Icons.flutter_dash, size: 100),
            SizedBox(height: 24),
            Text(
              'Flutter Clean MVVM',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
