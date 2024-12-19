import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rajivn_enterprises/services/database_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
    required String userName,
    required String email,
    required String phoneNumber,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Future<Map<String, dynamic>?> userData;

  @override
  void initState() {
    super.initState();
    String userId = _auth.currentUser!.uid; // Get current user's UID
    userData = DatabaseService(uid: userId).getUserDataByUid(); // Fetch user data from Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.teal], // Black at the top, teal at the bottom
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Custom AppBar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to the previous screen
                    },
                  ),
                  Expanded(
                    child: const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Placeholder for symmetry
                ],
              ),
              const SizedBox(height: 40),
              // Profile Photo with Camera Icon
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[900],
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () {
                        // Add logic for changing profile picture
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.tealAccent,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // User Details Section
              FutureBuilder<Map<String, dynamic>?>(
                future: userData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.hasData) {
                    var data = snapshot.data!;
                    String userName = data['fullname'] ?? 'No name';
                    String email = data['email'] ?? 'No email';
                    String phoneNumber = data['phoneNumber'] ?? 'No phone number';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildUserDetail("Name", userName),
                        const SizedBox(height: 10),
                        _buildUserDetail("Email", email),
                        const SizedBox(height: 10),
                        _buildUserDetail("Phone Number", phoneNumber),
                      ],
                    );
                  } else {
                    return const Center(child: Text('No data found.', style: TextStyle(color: Colors.white)));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Widget for User Details
  Widget _buildUserDetail(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800], // Background for details section
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
