import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rajivn_enterprises/helper/helper_function.dart';
import 'package:rajivn_enterprises/pages/auth/register_page.dart';
import 'package:rajivn_enterprises/pages/home_page.dart';
import 'package:rajivn_enterprises/services/auth_service.dart';
import 'package:rajivn_enterprises/services/database_service.dart';

import '../../widgets/widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       backgroundColor: Theme.of(context).primaryColor,
       elevation: 0,
     ),
     body: SingleChildScrollView(
       child: Padding(
         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
         child: Form(
           key: formKey,
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.center,
             children: <Widget>[
               const Text("Rajiv Enterprises", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
               ),
               const SizedBox(height: 20),

               Image.asset("assets/images/login.png"),
               TextFormField(
                 decoration: textInputDecoration.copyWith(
                   labelText: "Email",
                   prefixIcon: const Icon(Icons.email,
                   color: Colors.amber,) ),
                 onChanged: (val) {
                   setState(() {
                     email = val;
                   });
                 },
                 // check tha validation
                 validator: (val) {
                   return RegExp(
                       r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                       .hasMatch(val!)
                       ? null
                       : "Please enter a valid email";
                 },
               ),
               const SizedBox(height: 15),
               TextFormField(
                 obscureText: true,
                 decoration: textInputDecoration.copyWith(
                   labelText: "Password",
                   prefixIcon: const Icon(Icons.lock,
                     color: Colors.amber,),),

                 validator: (val) {
                   if (val!.length < 6) {
                     return "Password must be at least 6 characters";
                   } else {
                     return null;
                   }
                 },

                 onChanged: (val) {
                   setState(() {
                     password = val;
                   });
                 },
               ),

               const SizedBox(
                 height: 20,
               ),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                       backgroundColor: Theme.of(context).primaryColor,
                       elevation: 0,
                       shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(30))),
                   child: const Text(
                     "Sign In",
                     style:
                     TextStyle(color: Colors.white, fontSize: 16),
                   ),
                   onPressed: () {
                     login();
                   },
                 ),
               ),
               const SizedBox(
                 height: 10,
               ),
               Text.rich(TextSpan(
                 text: "Don't have an account? ",
                 style: const TextStyle(
                     color: Colors.black, fontSize: 14),
                 children: <TextSpan>[
                   TextSpan(
                       text: "Register here",
                       style: const TextStyle(
                           color: Colors.black,
                           decoration: TextDecoration.underline),
                       recognizer: TapGestureRecognizer()
                         ..onTap = () {
                           nextScreen(context, const RegisterPage());
                         }),
                 ],
               )),
             ],
           )),
       ),
     ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginWithUserNameandPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
          await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
              .gettingUserData(email);
          // saving the values to our shared preferences
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(snapshot.docs[0]['fullName']);
          nextScreenReplace(context, const HomePage(title: 'HomePage',));
        } else {
          showSnackbar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}