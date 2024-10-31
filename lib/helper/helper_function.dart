import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {

  //keys
  // ignore: non_constant_identifier_names
  static String UserLoggedInKey = "LOGGEDINKEY";
  // ignore: non_constant_identifier_names
  static String UserEmailKey = "USEREMAILKEY";
  // ignore: non_constant_identifier_names
  static String UserNameKey = "USERNAMEKEY";


  // Saving the data to shared preference
  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(UserLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSF(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(UserNameKey, userName);
  }

  static Future<bool> saveUserEmailSF(String userEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(UserEmailKey, userEmail);
  }


  //getting the data from shared preference
  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(UserLoggedInKey);
  }

  static Future<String?> getUserEmailFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(UserEmailKey);
  }

  static Future<String?> getUserNameFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(UserNameKey);
  }
}
