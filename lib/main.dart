import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rajivn_enterprises/pages/auth/login_page.dart';
import 'package:rajivn_enterprises/pages/home_page.dart';
import 'package:rajivn_enterprises/shared/constants.dart';
import 'firebase_options.dart';
import 'helper/helper_function.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async {
    await HelperFunction.getUserLoggedInStatus().then((value) {
      if (value != null) {
        _isSignedIn = value;
      }
    });
  }


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Constants().primaryColor,
        scaffoldBackgroundColor: Colors.white,

      ),
      debugShowCheckedModeBanner: false,
      home: _isSignedIn ?  const HomePage(title: "title") : const LoginPage(),
    );
  }
}