import 'package:rajivn_enterprises/helper/helper_function.dart';
import 'package:rajivn_enterprises/pages/auth/login_page.dart';
import 'package:rajivn_enterprises/pages/machinery_entry_page.dart';
import 'package:rajivn_enterprises/pages/profile_page.dart';
import 'package:rajivn_enterprises/pages/search_page.dart';
import 'package:rajivn_enterprises/services/auth_service.dart';
import 'package:rajivn_enterprises/services/database_service.dart';
import 'package:rajivn_enterprises/widgets/machinery_entry_tile.dart';
import 'package:rajivn_enterprises/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required String title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? machineryEntries;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {
    // Retrieve user data from shared preferences or any helper functions
    // Assuming HelperFunctions are properly set up in your project
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

    // Retrieve machinery entries for this user
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserMachineryEntries()
        .then((snapshot) {
      setState(() {
        machineryEntries = snapshot as Stream?;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(context, const SearchPage());
              },
              icon: const Icon(
                Icons.search,
              ))
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Machinery Tracker",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
      ),
      drawer: Drawer(
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
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              const Divider(
                height: 2,
              ),
              ListTile(
                onTap: () {},
                selectedColor: Theme.of(context).primaryColor,
                selected: true,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.settings),
                title: const Text(
                  "Dashboard",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () {
                  nextScreenReplace(
                      context,
                      ProfilePage(
                        userName: userName,
                        email: email,
                      ));
                },
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.account_circle),
                title: const Text(
                  "Profile",
                  style: TextStyle(color: Colors.black),
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
                                        builder: (context) => const LoginPage()),
                                        (route) => false);
                              },
                              icon: const Icon(
                                Icons.done,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        );
                      });
                },
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.exit_to_app),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.black),
                ),
              )
            ],
          )),
      body: machineryEntryList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nextScreen(context, const MachineryEntryPage());
        },
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  // Display list of machinery entries
  machineryEntryList() {
    return StreamBuilder(
      stream: machineryEntries,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['entries'] != null && snapshot.data['entries'].length != 0) {
            return ListView.builder(
              itemCount: snapshot.data['entries'].length,
              itemBuilder: (context, index) {
                int reverseIndex = snapshot.data['entries'].length - index - 1;
                return MachineryEntryTile(
                  entryId: snapshot.data['entries'][reverseIndex].id,
                  entryData: snapshot.data['entries'][reverseIndex].data(),
                  userName: userName, machineryName: '', siteName: '', endTime: '', driverName: '', startTime: '',
                );
              },
            );
          } else {
            return noEntriesWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }

  // Display message if there are no entries
  noEntriesWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              nextScreen(context, const MachineryEntryPage());
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "No machinery entries found. Tap the add icon to create an entry.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

