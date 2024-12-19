import 'package:flutter/material.dart';
import 'package:rajivn_enterprises/pages/auth/login_page.dart';
import 'package:rajivn_enterprises/pages/admin_add_new_site.dart';

import 'admin_profile.dart';

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Apply a gradient background to the body
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple[900]!], // Black to dark purple gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              title: Text(
                'Admin Dashboard',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent, // Make AppBar background transparent
              centerTitle: true,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer(); // Opens the drawer
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          colors: [Colors.purple, Colors.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(rect);
                      },
                      child: Text(
                        'Welcome, Admin!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildDashboardCard(
                            icon: Icons.add_location_alt,
                            label: 'Add New Site',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AddNewSitePage()),
                              );
                            },
                          ),

                          _buildDashboardCard(
                            icon: Icons.construction,
                            label: 'Add New Machine',
                            onTap: () {
                              // Navigate to Add Machine page
                            },
                          ),
                          _buildDashboardCard(
                            icon: Icons.delete_forever,
                            label: 'Delete User',
                            onTap: () {
                              // Navigate to Delete User page
                            },
                          ),
                          _buildDashboardCard(
                            icon: Icons.table_view,
                            label: 'View Records',
                            onTap: () {
                              // Navigate to View Records page
                            },
                          ),
                          _buildDashboardCard(
                            icon: Icons.local_gas_station,
                            label: 'View Diesel Entry',
                            onTap: () {
                              // Navigate to View Diesel Entry page
                            },
                          ),
                          _buildDashboardCard(
                            icon: Icons.analytics,
                            label: 'Generate Reports',
                            onTap: () {
                              // Navigate to Reports page
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black, // Keep the background black for the drawer
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black87, // Dark background for the header
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Drawer Options
            _buildDrawerOption(
              icon: Icons.person,
              label: 'Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminProfilePage()),
                );
              },
            ),
            _buildDrawerOption(
              icon: Icons.home,
              label: 'Home',
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            _buildDrawerOption(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ); // Navigate to Login Page
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create the drawer options with gradient icons
  Widget _buildDrawerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            colors: [Colors.purple, Colors.blue], // Gradient for drawer icons
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(rect);
        },
        child: Icon(icon, color: Colors.white), // Apply gradient to icons
      ),
      title: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    colors: [Colors.purple, Colors.blue], // Gradient for icons
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(rect);
                },
                child: Icon(icon, size: 50, color: Colors.white), // Apply gradient to icons
              ),
              SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
