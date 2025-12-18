import 'package:flutter/material.dart';
import 'login.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: const Color(0xFF102C57),
            ),

            const SizedBox(height: 15),

            // Username placeholder
            const Text(
              'Guest User',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            // Email placeholder
            const Text(
              'guest@example.com',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 30),

            // Placeholder options
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
              onTap: () {},
            ),
            _profileTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
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
