
import 'package:flutter/material.dart';
import 'adminlogin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Venue Hall Booking Admin',
      home: const AdminLoginPage(),
    );
  }
}
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'Welcome Admin 👋',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
