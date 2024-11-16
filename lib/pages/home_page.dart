import 'package:flutter/material.dart';
import 'package:rajivn_enterprises/pages/machinery_entry_page.dart';
import 'package:rajivn_enterprises/pages/diesel_entry_page.dart';
import 'package:rajivn_enterprises/pages/maintenance_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required String title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            children: const [
              Icon(Icons.account_circle, size: 150, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                "User Name",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: Colors.grey),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.white),
                title: Text(
                  "Settings",
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
