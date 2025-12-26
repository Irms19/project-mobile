import 'package:bookinghall/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'services/auth_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Update this line to use the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthLayout(pageIfNotConnected: LoginPage()), // or your landing page
    );
  }
}


