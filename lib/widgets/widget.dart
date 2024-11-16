import 'package:flutter/material.dart';

// TextInputDecoration is a reusable decoration for input fields
const textInputDecoration = InputDecoration(
    labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
    ),
    errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
    ),
);

// Function to navigate to the next screen without replacing the current screen
void nextScreen(BuildContext context, Widget page) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
    );
}

// Function to navigate to the next screen and replace the current screen
void nextScreenReplace(BuildContext context, Widget page) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
    );
}

// Function to show a snackbar message
void showSnackbar(BuildContext context, Color color, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                message,
                style: const TextStyle(fontSize: 14),
            ),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
                label: "OK",
                onPressed: () {},
                textColor: Colors.white,
            ),
        ),
    );
}
