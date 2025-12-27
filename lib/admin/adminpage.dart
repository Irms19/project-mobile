import 'package:flutter/material.dart';
import 'package:bookinghall/login.dart';
import 'managehall.dart';
import 'manageusers.dart';
import 'adminmanagebooking.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  static const Color darkBlue = Color(0xFF102C57);
  static const Color accentGold = Color(0xFFE1AA74);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Brighter, cleaner background
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        title: const Text(
          'ADMIN PANEL',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Profile / Logo Section
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: darkBlue.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    'assets/catlogo2.jpg',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Welcome Back, Administrator",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 35),

            // Action Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: darkBlue,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: darkBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  _AdminButton(
                    icon: Icons.storefront_outlined,
                    text: 'MANAGE HALLS',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageHallPage())),
                  ),
                  const SizedBox(height: 16),
                  _AdminButton(
                    icon: Icons.group_add_outlined,
                    text: 'MANAGE USERS',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageUsersPage())),
                  ),
                  const SizedBox(height: 16),
                  _AdminButton(
                    icon: Icons.calendar_today_outlined,
                    text: 'MANAGE BOOKINGS',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminManageBookingPage())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  void _handleLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }
}

class _AdminButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _AdminButton({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55, // Slightly taller for better touch target
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AdminDashboardPage.darkBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        icon: Icon(icon, size: 22),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.8),
        ),
        onPressed: onTap,
      ),
    );
  }
}