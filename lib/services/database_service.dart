import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // Collection references
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users");
  final CollectionReference machineryEntriesCollection =
  FirebaseFirestore.instance.collection("machinery_entries");
  final CollectionReference sitesCollection =
  FirebaseFirestore.instance.collection("sites");
  final CollectionReference machineTypesCollection =
  FirebaseFirestore.instance.collection("machine_types");
  final CollectionReference dieselEntriesCollection =
  FirebaseFirestore.instance.collection("diesel_entries");

  // Saving user data
  Future saveUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullname": fullName,
      "email": email,
    });
  }

  // Getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
    await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
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
    return await machineryEntriesCollection.add({
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
    return await machineryEntriesCollection
        .where("userId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .get();
  }

  // Adding a diesel refill entry
  Future addDieselEntry({
    required String machineID,
    required double amount,
    required DateTime refillTime,
    required String siteName,
  }) async {
    return await dieselEntriesCollection.add({
      "userId": uid,
      "machineID": machineID,
      "amount": amount,
      "refillTime": refillTime,
      "siteName": siteName,
    });
  }

  // Adding a new site
  Future addSite(String siteName) async {
    return await sitesCollection.add({
      "siteName": siteName,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // Adding a machine to machine_types collection
  Future addMachineType({
    required String machineType,
    required String machineID,
  }) async {
    DocumentReference machineTypeDoc = machineTypesCollection.doc(machineType);
    CollectionReference machinesSubcollection = machineTypeDoc.collection("machines");

    return await machinesSubcollection.doc(machineID).set({
      "machineID": machineID,
      "isActive": true,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // Fetching user data by email
  Future getUserDataByEmail(String email) async {
    QuerySnapshot snapshot =
    await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  // Fetching all machinery entries
  Future getAllMachineryEntries() async {
    QuerySnapshot snapshot = await machineryEntriesCollection.get();
    return snapshot;
  }
}
