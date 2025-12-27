import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookinghall/services/auth_service.dart';
import 'package:bookinghall/services/auth_layout.dart';
import 'guestpage.dart';
import 'signup_page.dart';
import 'services/resetPassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String errorMessage = '';
  bool isLoading = false;

  // Login Logic
  void login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await authService.value.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // SUCCESS LOGIC:
      if (mounted) {
        // This clears the stack (GuestPage & LoginPage) and restarts at AuthLayout
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthLayout(pageIfNotConnected: LoginPage()),
          ),
              (route) => false,
        );
      }

    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'invalid-credential') {
          errorMessage = 'Invalid email or password. Please try again.';
        } else if (e.code == 'user-not-found') {
          errorMessage = 'No account exists with this email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password.';
        } else if (e.code == 'user-disabled') {
          errorMessage = 'This account has been disabled.';
        } else if (e.code == 'too-many-requests') {
          errorMessage = 'Too many failed attempts. Please try again later.';
        } else {
          // Fallback for any other technical error
          errorMessage = 'Login failed. Please check your credentials.';
        }
      });
    } catch (e) {
      setState(() => errorMessage = 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Welcome",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),


                  Image.asset(
                    'assets/catlogo2.jpg',
                    width: 150,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                  ),

                  const SizedBox(height: 30),

                  // Error Message Display
                  if (errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter your email";
                      if (!value.contains('@')) return "Please enter a valid email";
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (value) => value!.isEmpty ? "Please enter your password" : null,
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const resetPasswordPage())
                        );
                      },
                      child: const Text("Forgot Password?"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Login button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF102C57),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: isLoading ? null : () {
                        if (_formKey.currentState!.validate()) {
                          login();
                        }
                      },
                      child: isLoading
                          ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                          : const Text(
                          "Login",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const GuestPage()));
                    },
                    child: const Text(
                      'CONTINUE AS GUEST',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpPage())
                          );
                        },
                        child: const Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold)),
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