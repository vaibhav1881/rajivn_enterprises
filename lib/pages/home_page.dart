import 'package:flutter/material.dart';
import 'package:rajivn_enterprises/pages/machinery_entry_page.dart';
import 'package:rajivn_enterprises/pages/diesel_entry_page.dart';
import 'package:rajivn_enterprises/pages/maintenance_page.dart';
import 'package:rajivn_enterprises/pages/profile_page.dart';
import 'package:rajivn_enterprises/pages/auth/login_page.dart';
import 'package:rajivn_enterprises/services/auth_service.dart';
import 'package:rajivn_enterprises/helper/helper_function.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required String title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {
    // Retrieve user data from shared preferences or any helper functions
    await HelperFunction.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });

    await HelperFunction.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text(
          "Machinery Tracker",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 27,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // White hamburger menu
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.black,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            children: <Widget>[
              Icon(
                Icons.account_circle,
                size: 150,
                color: Colors.grey[700],
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                userName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Divider(
                height: 2,
                color: Colors.grey,
              ),
              ListTile(
                onTap: () {},
                selectedColor: Colors.blue,
                selected: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.dashboard, color: Colors.white),
                title: const Text(
                  "Dashboard",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        userName: userName,
                        email: email,
                      ),
                    ),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.account_circle, color: Colors.white),
                title: const Text(
                  "Profile",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                onTap: () async {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await authService.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                    (route) => false,
                              );
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.exit_to_app, color: Colors.white),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50), // Adjust spacing from top
          // Machine Entry Card
          _buildCard(
            title: "Machine Entry",
            icon: Icons.construction,
            gradientColors: [Colors.teal, Colors.tealAccent],
            textColor: Colors.white, // Text color for Machine Entry card
            titleColor: Colors.white, // Title color for contrast
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MachineryEntryPage()),
              );
            },
          ),
          // Diesel Entry Card (removed white gradient)
          _buildCard(
            title: "Diesel Entry",
            icon: Icons.local_gas_station,
            gradientColors: [Colors.orange, Colors.deepOrangeAccent], // Solid orange gradient
            textColor: Colors.white, // Text color for Diesel Entry card
            titleColor: Colors.white, // Title color for contrast
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DieselEntryPage()),
              );
            },
          ),
          // Maintenance Card (removed white gradient)
          _buildCard(
            title: "Maintenance",
            icon: Icons.build_circle_outlined,
            gradientColors: [Colors.purple, Colors.purpleAccent], // Solid purple gradient
            textColor: Colors.white, // Text color for Maintenance card
            titleColor: Colors.white, // Title color for contrast
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MaintenancePage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Reusable function to build a card with dynamic colors
  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required Color textColor,
    required Color titleColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Adjust spacing between cards
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 120, // Reduced card height
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 40, color: textColor), // Keep icon color unchanged
              Text(
                title,
                style: TextStyle(
                  color: titleColor, // Title color
                  fontSize: 20, // Adjusted text size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
