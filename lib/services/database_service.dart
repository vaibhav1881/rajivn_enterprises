import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});

  // Collection references
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users");

  // Saving user data (including phone number)
  Future saveUserData(String fullName, String email, String phoneNumber) async {
    return await userCollection.doc(uid).set({
      "fullname": fullName,
      "email": email,
      "phoneNumber": phoneNumber, // Save the phone number
    });
  }

  // Getting user data by email
  Future<Map<String, dynamic>?> getUserDataByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await userCollection.where("email", isEqualTo: email).get();
      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching user data by email: $e");
    }
    return null;
  }

  // Getting user data by uid (for profile page)
  Future<Map<String, dynamic>?> getUserDataByUid() async {
    try {
      DocumentSnapshot snapshot = await userCollection.doc(uid).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching user data by UID: $e");
    }
    return null;
  }

  // Check if the user is admin
  Future<bool> isAdmin(String email) async {
    try {
      // Admin credentials
      const String adminEmail = "bhagwatvr2004@gmail.com";
      const String adminPassword = "12345678";

      // Retrieve the user's email and password from Firestore
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      if (userDoc.exists) {
        String email = userDoc['email'];
        String password = userDoc['password']; // Store password securely if required
        return email == adminEmail && password == adminPassword;
      }
    } catch (e) {
      print("Error checking if user is admin: $e");
    }
    return false;
  }

  // Adding a new machinery entry
  Future addMachineryEntry({
    required String machineType,
    required String machineID,
    required DateTime startHour,
    required DateTime stopHour,
    required String siteName,
    required String driverID,
    required double dieselEntry,
    String? imagePath,
  }) async {
    return await FirebaseFirestore.instance.collection("machinery_entries").add({
      "userId": uid,
      "machineType": machineType,
      "machineID": machineID,
      "startHour": startHour,
      "stopHour": stopHour,
      "siteName": siteName,
      "driverID": driverID,
      "dieselEntry": dieselEntry,
      "imageUrl": imagePath, // Firebase Storage path to the image
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // Fetching machinery entries for the current user
  Future<QuerySnapshot> getUserMachineryEntries() async {
    return await FirebaseFirestore.instance
        .collection("machinery_entries")
        .where("userId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .get();
  }

  // Fetching all machinery entries
  Future getAllMachineryEntries() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("machinery_entries").get();
    return snapshot;
  }
}
