import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookinghall/services/auth_service.dart';
import 'login.dart';
import 'MyBookingsPage.dart';
import 'services/auth_layout.dart';
import 'services/ChangePasswordPage.dart';
import 'package:bookinghall/EditProfilePage.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      // We listen to the user's document in real-time
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          // Show a loader if data is still fetching
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // Get the data map
          Map<String, dynamic> userData = {};
          if (snapshot.hasData && snapshot.data!.exists) {
            userData = snapshot.data!.data() as Map<String, dynamic>;
          }

          String displayName = userData['username'] ?? userData['name'] ?? "User";

          return Scaffold(
            backgroundColor: const Color(0xFFFBFBFB),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xFF102C57),
              title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // --- 1. HEADER SECTION ---
                  _buildGreetingHeader(displayName, user?.email),

                  const SizedBox(height: 30),

                  // --- 2. MENU SECTION ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _profileTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profile',
                          onTap: () {
                            // NOW IT WORKS: Passing the userData we got from the Stream
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(userData: userData),
                              ),
                            );
                          },
                        ),
                        _profileTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Change Password',
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ChangePasswordPage())
                            );
                          },
                        ),
                        _profileTile(
                          icon: Icons.bookmark_border_rounded,
                          title: 'My Bookings',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MyBookingsPage()),
                            );
                          },
                        ),
                        const Divider(height: 40, thickness: 1),
                        _profileTile(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          isLogout: true,
                          onTap: () async {
                            await authService.value.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const AuthLayout(pageIfNotConnected: LoginPage()),
                                ),
                                    (route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  // --- Header logic simplified because data is passed in ---
  Widget _buildGreetingHeader(String name, String? email) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF102C57),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 50, top: 30, left: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Hi, $name!",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email ?? 'No email found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLogout ? Colors.red.withOpacity(0.1) : const Color(0xFF102C57).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isLogout ? Colors.red : const Color(0xFF102C57), size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : const Color(0xFF102C57),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}