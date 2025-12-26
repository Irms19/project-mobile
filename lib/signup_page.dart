import 'package:bookinghall/guestpage.dart';
import 'package:bookinghall/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bookinghall/services/auth_layout.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController controllerUsername = TextEditingController();
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();
  final TextEditingController controllerConfirmPassword = TextEditingController();

  bool obscurePassword = true;
  String errorMessage = '';
  bool isLoading = false; // Added loading state for button consistency

  void register() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await authService.value.createAccount(
        email: controllerEmail.text.trim(),
        password: controllerPassword.text.trim(),
        username: controllerUsername.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const AuthLayout(pageIfNotConnected: GuestPage()),
          ),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'An error occurred';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Create Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Matching the Login Page Logo
                  Center(
                    child: Image.asset(
                      'assets/catlogo2.jpg',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person_add_outlined, size: 80, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Error Message Display
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),

                  // Username Field
                  TextFormField(
                    controller: controllerUsername,
                    decoration: InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) => value!.isEmpty ? "Enter a username" : null,
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter an email';
                      if (!value.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: controllerPassword,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    validator: (value) => value!.length < 6 ? "Minimum 6 characters" : null,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: controllerConfirmPassword,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.lock_clock),
                    ),
                    validator: (value) => value != controllerPassword.text ? "Passwords do not match" : null,
                  ),

                  const SizedBox(height: 30),

                  // Sign Up Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF102C57),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: isLoading ? null : () {
                      if (formKey.currentState!.validate()) {
                        register();
                      }
                    },
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}