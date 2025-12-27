import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookinghall/services/auth_service.dart'; // Ensure this path is correct

class resetPasswordPage extends StatefulWidget {
  const resetPasswordPage({super.key});

  @override
  State<resetPasswordPage> createState() => _resetPasswordPageState();
}

class _resetPasswordPageState extends State<resetPasswordPage> {
  final _emailController = TextEditingController();
  bool isLoading = false;

  // Using your specific AuthService method
  Future<void> _handleReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      // Calling your function directly
      await authService.value.resetPassword(email: email);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Email Sent"),
        content: const Text("A password reset link has been sent to your inbox."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to Profile
            },
            child: const Text("Back to Profile"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF102C57)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reset Password",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF102C57),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "We will send a secure link to your email to verify your identity and reset your password.",
              style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 40),

            // Textfield
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF102C57)),
                filled: true,
                fillColor: const Color(0xFFFBFBFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF102C57),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Send Link",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}