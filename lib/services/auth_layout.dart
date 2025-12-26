import 'package:bookinghall/guestpage.dart';
import 'package:bookinghall/mainpage.dart';
import 'package:bookinghall/services/app_loading_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'package:bookinghall/login.dart';


class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.pageIfNotConnected
  });

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, service, child) {
        return StreamBuilder<User?>(
          stream: service.authStateChanges,
          builder: (context, snapshot) {
            // 1. Show loading screen while connecting to Firebase
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingPage();
            }

            // 2. Check if user is logged in
            if (snapshot.hasData) {
              return const MainPage();
            }

            // 3. If NOT logged in, return the fallback page
            // Direct return is cleaner than using a 'widget' variable
            return pageIfNotConnected ?? const LoginPage();
          },
        );
      },
    );
  }
}
