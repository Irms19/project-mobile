import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookinghall/services/auth_service.dart'; // Import your auth service
import 'login.dart';
import 'MyBookingsPage.dart';
import 'services/auth_layout.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the current logged-in user from Firebase Auth
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF102C57),
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Profile Avatar
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/AZAM.jpg'),
              backgroundColor: Color(0xFF102C57),
            ),

            const SizedBox(height: 15),

            // 2. Use FutureBuilder to fetch the Username from Firestore
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: Color(0xFF102C57));
                }

                // Default values if data isn't found
                String displayName = "User";
                if (snapshot.hasData && snapshot.data!.exists) {
                  displayName = snapshot.data!['username'] ?? "User";
                }

                return Column(
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user?.email ?? 'No email found',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            _profileTile(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {},
            ),
            _profileTile(
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () {},
            ),
            _profileTile(
              icon: Icons.bookmark,
              title: 'My Bookings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyBookingsPage()),
                );
              },
            ),

            // 3. Updated Logout to actually sign the user out
            _profileTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                // 1. Perform the sign out
                await authService.value.signOut();

                // 2. Clear the navigation stack and go back to the root
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const AuthLayout(pageIfNotConnected: LoginPage()),
                    ),
                        (route) => false, // This removes all previous pages from memory
                  );
                }
              },
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : const Color(0xFF102C57),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}