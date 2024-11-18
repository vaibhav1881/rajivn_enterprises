import 'package:flutter/material.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Teal background for the AppBar
        title: const Text(
          "Maintenance",
          style: TextStyle(
            color: Colors.white, // White text for the title
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, // Back arrow icon
            color: Colors.white, // White color for the arrow
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.teal], // Black to teal gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Text(
            "Maintenance Page Content",
            style: TextStyle(
              color: Colors.white, // White text for content
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
