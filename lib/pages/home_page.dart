import 'package:flutter/material.dart';
import 'package:rajivn_enterprises/pages/machinery_entry_page.dart';
import 'package:rajivn_enterprises/pages/diesel_entry_page.dart';
import 'package:rajivn_enterprises/pages/maintenance_page.dart';
import 'package:rajivn_enterprises/pages/profile_page.dart';
import 'package:rajivn_enterprises/pages/auth/login_page.dart';
import 'package:rajivn_enterprises/services/auth_service.dart';
import 'package:rajivn_enterprises/helper/helper_function.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "No Name";
  String email = "No Email";
  String phoneNumber = "No Phone";
  AuthService authService = AuthService();
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  Future<void> gettingUserData() async {
    try {
      String? emailValue = await HelperFunction.getUserEmailFromSF();
      String? userNameValue = await HelperFunction.getUserNameFromSF();
      String? phoneValue = await HelperFunction.getUserPhoneNumberFromSF();

      setState(() {
        email = emailValue ?? "No Email";
        userName = userNameValue ?? "No Name";
        phoneNumber = phoneValue ?? "No Phone";
      });
    } catch (e) {
      showCustomSnackbar(context, Colors.red, "Error loading user data: $e");
    }
  }

  void showCustomSnackbar(BuildContext context, Color color, String text) {
    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text(
                'DashBoard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true, // Center the title
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    _buildCard(
                      title: "Machine Entry",
                      icon: Icons.construction,
                      gradientColors: [Colors.teal, Colors.tealAccent],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MachineryEntryPage()),
                        );
                      },
                    ),
                    _buildCard(
                      title: "Diesel Entry",
                      icon: Icons.local_gas_station,
                      gradientColors: [Colors.orange, Colors.deepOrangeAccent],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DieselEntryPage()),
                        );
                      },
                    ),
                    _buildCard(
                      title: "Maintenance",
                      icon: Icons.build_circle_outlined,
                      gradientColors: [Colors.purple, Colors.purpleAccent],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MaintenancePage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: [
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 15),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.grey),
            _buildDrawerItem(
              title: "Dashboard",
              icon: Icons.dashboard,
              isSelected: selectedIndex == 0,
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              title: "Profile",
              icon: Icons.account_circle,
              isSelected: selectedIndex == 1,
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userName: userName,
                      email: email,
                      phoneNumber: phoneNumber,
                    ),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              title: "Logout",
              icon: Icons.exit_to_app,
              isSelected: false,
              onTap: () {
                _handleLogout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      selectedColor: Colors.blue,
      selected: isSelected,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 120,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
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
              icon: const Icon(Icons.cancel, color: Colors.red),
            ),
            IconButton(
              onPressed: () async {
                try {
                  await authService.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                  );
                } catch (e) {
                  Navigator.pop(context);
                  showCustomSnackbar(context, Colors.red, "Logout failed: $e");
                }
              },
              icon: const Icon(Icons.done, color: Colors.green),
            ),
          ],
        );
      },
    );
  }
}
