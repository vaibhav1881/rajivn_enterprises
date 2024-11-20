import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rajivn_enterprises/pages/auth/register_page.dart';
import 'package:rajivn_enterprises/pages/home_page.dart';
import 'package:rajivn_enterprises/services/auth_service.dart';
import 'package:rajivn_enterprises/services/database_service.dart';
import 'package:rajivn_enterprises/helper/helper_function.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/widget.dart';
import 'package:rajivn_enterprises/pages/admin_dashboard.dart';
import '../admin_dashboard.dart'; // Import your Admin Dashboard page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;

  final AuthService authService = AuthService();

  // Login function
  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Attempt login
        Object? loginSuccess = await authService.loginWithUserNameandPassword(context, email, password);

        if (loginSuccess != null) {
          // Fetch user data from Firestore using the correct method
          var snapshot = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
              .getUserDataByEmail(email);

          if (snapshot != null && snapshot.isNotEmpty) {
            // Save user data
            await HelperFunction.saveUserLoggedInStatus(true);
            await HelperFunction.saveUserEmailSF(email);
            await HelperFunction.saveUserNameSF(snapshot['fullname']);

            // Navigate to home
            nextScreenReplace(context, const HomePage());
          } else {
            showCustomSnackbar(context, Colors.red, "User data not found.");
          }
        } else {
          showCustomSnackbar(context, Colors.red, "Invalid credentials. Please try again.");
        }
      } catch (e) {
        showCustomSnackbar(context, Colors.red, "An error occurred: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gradient text for "Yogi Group"
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: const Text(
                  'Yogi Group',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Image
              Image.asset("assets/images/poclain5.png"), // Ensure this is correctly set in pubspec.yaml
              const SizedBox(height: 16),
              // Email input
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.email, color: Colors.amber),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Email cannot be empty";
                  }
                  return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                      .hasMatch(val)
                      ? null
                      : "Please enter a valid email";
                },
              ),
              const SizedBox(height: 12),
              // Password input
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.lock, color: Colors.amber),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Password cannot be empty";
                  } else if (val.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Sign-in button
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent[700],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  onPressed: login,
                ),
              ),
              const SizedBox(height: 10),
              // Register link
              Text.rich(TextSpan(
                text: "Don't have an account? ",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                children: <TextSpan>[
                  TextSpan(
                    text: "Register here",
                    style: const TextStyle(
                        color: Colors.white, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        nextScreen(context, const RegisterPage());
                      },
                  ),
                ],
              )),
              const SizedBox(height: 10),
              // Admin link
              Text.rich(
                TextSpan(
                  text: "Are you an Admin? ",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(
                      text: "Login as Admin",
                      style: const TextStyle(
                          color: Colors.tealAccent, decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          nextScreen(context, AdminHomePage()); // Replace with your admin dashboard page
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Utility functions
void nextScreenReplace(BuildContext context, Widget page) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}

void showCustomSnackbar(BuildContext context, Color color, String text) {
  final snackBar = SnackBar(
    content: Text(text),
    backgroundColor: color,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
