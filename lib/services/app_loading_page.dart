import 'package:flutter/material.dart';

class AppLoadingPage extends StatelessWidget {
  const AppLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your Cat Logo
            Image.asset(
              'assets/catlogo2.jpg',
              width: 120, // Adjusted size for a nice loading look
              height: 120,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.pets, size: 50), // Fallback if image fails
            ),

            const SizedBox(height: 30),

            // Simple Buffer (Progress Indicator)
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: Color(0xFF102C57), // Using your app's primary blue
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}