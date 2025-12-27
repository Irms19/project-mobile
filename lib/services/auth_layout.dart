import 'package:cloud_firestore/cloud_firestore.dart'; // IMPORTANT: Add this
import 'package:bookinghall/guestpage.dart';
import 'package:bookinghall/mainpage.dart';
import 'package:bookinghall/admin/adminpage.dart'; // Create/Import your Admin page
import 'package:bookinghall/services/app_loading_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'package:bookinghall/login.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.pageIfNotConnected});

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, service, child) {
        return StreamBuilder<User?>(
          stream: service.authStateChanges,
          builder: (context, snapshot) {
            // 1. Loading state (Checking Firebase Auth)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingPage();
            }

            // 2. If User is Logged In
            if (snapshot.hasData && snapshot.data != null) {
              // Now we check Firestore for the specific Role
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(snapshot.data!.uid)
                    .get(),
                builder: (context, userSnapshot) {
                  // Show loading while fetching the Firestore Document
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingPage();
                  }

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    final String role = userData['role'] ?? 'user';

                    // --- REDIRECT BASED ON ROLE ---
                    if (role == 'admin') {
                      return const AdminDashboardPage();
                    } else {
                      return const MainPage();
                    }
                  }

                  // Fallback if document doesn't exist yet
                  return const MainPage();
                },
              );
            }

            // 3. If NOT logged in, show Login or Guest
            return pageIfNotConnected ?? const LoginPage();
          },
        );
      },
    );
  }
}