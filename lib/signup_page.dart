import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        centerTitle: true,
        title: const Text("Login or Sign Up"),
        elevation: 0,
      ),
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // Logo placeholder
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.image_outlined, size: 60),
              ),
            ),

            const SizedBox(height: 25),

            _inputLabel("Enter your username"),
            _inputField(),

            _inputLabel("Enter your email"),
            _inputField(keyboard: TextInputType.emailAddress),

            _inputLabel("Enter your phone number"),
            _inputField(keyboard: TextInputType.phone),

            _inputLabel("Enter your password"),
            _passwordField(),

            const SizedBox(height: 30),

            // Sign up button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // sign up logic here
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Terms text
            const Text(
              "By logging or registering, you agree to our Terms of Service,\n"
                  "Privacy Policy and personal Data Protection Policy",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Input label widget
  Widget _inputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500
          ),
        ),
      ),
    );
  }

  // Normal input field
  Widget _inputField({TextInputType keyboard = TextInputType.text}) {
    return TextField(
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: "Input Text",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        isDense: true,
      ),
    );
  }

  // Password field
  Widget _passwordField() {
    return TextField(
      obscureText: obscurePassword,
      decoration: InputDecoration(
        hintText: "Input Text",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        isDense: true,
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
      ),
    );
  }
}
