import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewSitePage extends StatefulWidget {
  const AddNewSitePage({super.key});

  @override
  _AddNewSitePageState createState() => _AddNewSitePageState();
}

class _AddNewSitePageState extends State<AddNewSitePage> {
  final TextEditingController _siteNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white, // White arrow
        ),
        title: const Text("Add New Site"),
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C1C1C), // Black at the top
              Color(0xFF4A0072), // Dark purple at the bottom
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  _buildCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Site Name",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextInputField(_siteNameController, "Enter Site Name"),
                          const SizedBox(height: 16),
                          const Text(
                            "Location",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextInputField(_locationController, "Enter Location"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      print("Add Site Button Pressed");
                      addNewSite();
                    },
                    child: const Text(
                      "Add Site",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 8,
                      shadowColor: Colors.tealAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Text Input Field
  Widget _buildTextInputField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black.withOpacity(0.5), // Semi-transparent black
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return "This field cannot be empty";
        }
        return null;
      },
    );
  }

  // Custom Card
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // Add Site Function
  Future<void> addNewSite() async {
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed");
      return;
    }

    try {
      print("Attempting to add site...");
      await FirebaseFirestore.instance.collection('sites').add({
        'siteName': _siteNameController.text.trim(),
        'location': _locationController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Site added successfully");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Site added successfully!")),
      );

      // Clear input fields
      _siteNameController.clear();
      _locationController.clear();
    } catch (e) {
      print("Error adding site: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding site: $e")),
      );
    }
  }
}
