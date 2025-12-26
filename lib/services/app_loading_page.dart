import 'package:flutter/material.dart';

class AppLoadingPage extends StatelessWidget {
  const AppLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Matches your SignUpPage
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your App Logo or a Booking Icon
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.calendar_today_rounded, // Booking related icon
                size: 50,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            // Modern Circular Progress Indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 3,
              ),
            ),

            const SizedBox(height: 16),

            // Loading Text
            Text(
              "BookingHall",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}