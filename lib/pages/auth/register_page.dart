import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rajivn_enterprises/helper/helper_function.dart';
import 'package:rajivn_enterprises/pages/auth/login_page.dart'; // Correct import for LoginPage
import 'package:rajivn_enterprises/pages/home_page.dart'; // Correct import for HomePage
import 'package:rajivn_enterprises/services/auth_service.dart';
import 'package:rajivn_enterprises/widgets/widget.dart'; // Import widget.dart

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullName = "";
  String phoneNumber = "";
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Dark background
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0, // No elevation
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.white, Colors.teal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: const Text(
                        "Yogi Group",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Create your account to explore...!",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Full Name Field
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  labelText: "Full Name",
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.person, color: Colors.amber),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    fullName = val;
                  });
                },
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Name cannot be empty";
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  labelText: "Email",
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
                  return RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(val!)
                      ? null
                      : "Please enter a valid email";
                },
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  labelText: "Phone Number",
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.phone, color: Colors.amber),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    phoneNumber = val;
                  });
                },
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Phone number cannot be empty";
                  } else if (val.length < 10) {
                    return "Enter a valid phone number";
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.lock, color: Colors.amber),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) {
                  if (val!.length < 6) {
                    return "Password must be at least 6 characters";
                  } else {
                    return null;
                  }
                },
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Register Button
              _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
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
                    "Register",
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  onPressed: register,
                ),
              ),
              const SizedBox(height: 16),

              // Already have an account
              Center(
                child: Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Login now",
                        style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            nextScreen(context, const LoginPage());
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Registration method
  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading spinner
      });

      try {
        // Attempt to register the user with the provided details
        Object? result = await authService.registerUserWithEmailandPassword(
          fullName, email, password, phoneNumber,
        );

        // Check if registration is successful
        if (result != null) {
          // Once registration is successful, save user data in HelperFunction
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(fullName);

          // Now navigate to the home page
          debugPrint("User registered successfully!");
          showSnackbar(context, Colors.green, "You're registered! :)");

          // Ensure navigation to the HomePage
          nextScreen(context, const HomePage());
        } else {
          // If registration fails, show error message
          debugPrint("Registration failed: $result");
          showSnackbar(context, Colors.red, result.toString());
        }
      } catch (e) {
        // Catch any errors during registration
        debugPrint("Error during registration: $e");
        showSnackbar(context, Colors.red, "Registration error: $e");
      } finally {
        setState(() {
          _isLoading = false; // Hide loading spinner after process completes
        });
      }
    }
  }
}
