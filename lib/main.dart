import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'flutterfire_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: firebaseOptions,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Firebase Initialized!')),
      ),
    );
  }
}
