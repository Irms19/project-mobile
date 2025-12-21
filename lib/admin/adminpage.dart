import 'package:bookinghall/login.dart';
import 'package:flutter/material.dart';
import 'managehall.dart';
import 'manageusers.dart';
import 'adminmanagebooking.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  static const Color darkBlue = Color(0xFF102C57);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Top AppBar
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        title: const Text(
          'ADMIN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 30),

          // Image placeholder
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/catlogo2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Action buttons container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: darkBlue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: darkBlue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _AdminButton(
                  icon: Icons.meeting_room_outlined,
                  text: 'MANAGE HALLS',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManageHallPage()),
                    );
                  },
                ),
                const SizedBox(height: 15),
                _AdminButton(
                  icon: Icons.people_outline,
                  text: 'MANAGE USERS',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManageUsersPage()),
                    );
                  },
                ),
                const SizedBox(height: 15),
                _AdminButton(
                  icon: Icons.book_online_outlined,
                  text: 'MANAGE BOOKINGS',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminManageBookingPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom home bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: darkBlue,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.home,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _AdminButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _AdminButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0D47A1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(icon),
          label: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}
