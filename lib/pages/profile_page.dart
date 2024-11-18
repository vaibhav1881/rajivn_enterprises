import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rajivn_enterprises/services/database_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required String userName, required String email, required String phoneNumber}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Future<Map<String, dynamic>?> userData;

  @override
  void initState() {
    super.initState();
    String userId = _auth.currentUser!.uid;  // Get current user's UID
    userData = DatabaseService(uid: userId).getUserDataByUid(); // Fetch user data from Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white), // White title
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
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

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  _buildUserDetail("Name", userName),
                  const SizedBox(height: 10),
                  _buildUserDetail("Email", email),
                  const SizedBox(height: 10),
                  _buildUserDetail("Phone Number", phoneNumber),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }

  // Reusable Widget for User Details
  Widget _buildUserDetail(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.grey, Colors.grey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}