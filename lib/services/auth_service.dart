import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rajivn_enterprises/helper/helper_function.dart';
import 'package:rajivn_enterprises/pages/admin_dashboard.dart';
import 'package:rajivn_enterprises/pages/machinery_entry_page.dart';
import 'package:rajivn_enterprises/services/database_service.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Login with email and password
  Future<Object?> loginWithUserNameandPassword(
      BuildContext context, String email, String password) async {
    try {
      // Sign in with the provided email and password
      User user = (await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).user!;

      if (user != null) {
        // Check if the user is an admin or machine operator
        DatabaseService dbService = DatabaseService(uid: user.uid);

        // Fetch user data and check if they are an admin
        bool isAdmin = await dbService.isAdmin(email);

        // Save login state and user data to SharedPreferences
        await HelperFunction.saveUserLoggedInStatus(true);
        await HelperFunction.saveUserEmailSF(email);
        await HelperFunction.saveUserNameSF(user.displayName ?? "Unknown");

        // Navigate to Admin Dashboard if the user is an admin
        if (isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        } else {
          // Otherwise, navigate to the Machinery Entry Page (Machine Operator)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MachineryEntryPage()),
          );
        }

        return true;
      } else {
        return "Login failed, user not found.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message; // Return the error message in case of a failure
    }
  }

  // Register User with email and password
  Future<Object?> registerUserWithEmailandPassword(
      String fullName, String email, String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )).user!;

      if (user != null) {
        // Save user data to the database
        await DatabaseService(uid: user.uid).saveUserData(fullName, email);
        return true;
      } else {
        return "User registration failed.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message in case of failure
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Clear user data from SharedPreferences
      await HelperFunction.saveUserLoggedInStatus(false);
      await HelperFunction.saveUserEmailSF("");
      await HelperFunction.saveUserNameSF("");

      // Sign out from Firebase Auth
      await firebaseAuth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print("Error signing out: $e");
      }
    }
  }
}
