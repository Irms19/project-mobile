import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookinghall/services/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> _handleChangePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final currentPass = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    // Basic Validation
    if (currentPass.isEmpty || newPass.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }
    if (newPass.length < 6) {
      _showSnackBar("New password must be at least 6 characters");
      return;
    }
    if (newPass != confirmPass) {
      _showSnackBar("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);
    try {
      // Using your specific service method
      await authService.value.resetPasswordFromCurrentPassword(
        email: user?.email ?? '',
        currentPassword: currentPass,
        newPassword: newPass,
      );

      if (mounted) _showSuccessDialog();
    } catch (e) {
      _showSnackBar("Failed: Check if your current password is correct.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Password Updated"),
        content: const Text("Your security settings have been updated successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to Profile
            },
            child: const Text("Done"),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Update Security",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF102C57),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "For your security, please enter your current password to make changes.",
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
            const SizedBox(height: 35),

            _buildTextField(_currentPasswordController, "Current Password", Icons.lock_open_rounded),
            const SizedBox(height: 15),
            const Divider(height: 30),
            _buildTextField(_newPasswordController, "New Password", Icons.lock_outline_rounded),
            const SizedBox(height: 15),
            _buildTextField(_confirmPasswordController, "Confirm New Password", Icons.lock_reset_rounded),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF102C57),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Confirm Change",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF102C57)),
        filled: true,
        fillColor: const Color(0xFFFBFBFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}