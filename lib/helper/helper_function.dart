import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  // Keys for SharedPreferences
  static const String userLoggedInKey = "LOGGEDINKEY";
  static const String userEmailKey = "USEREMAILKEY";
  static const String userNameKey = "USERNAMEKEY";
  static const String userPhoneKey = "USERPHONEKEY"; // Added key for phone number

  // Saving the data to SharedPreferences
  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSF(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userNameKey, userName);
  }

  static Future<bool> saveUserEmailSF(String userEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userEmailKey, userEmail);
  }

  static Future<bool> saveUserPhoneNumberSF(String phoneNumber) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userPhoneKey, phoneNumber); // Save phone number
  }

  // Getting the data from SharedPreferences
  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getUserEmailFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future<String?> getUserNameFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }

  static Future<String?> getUserPhoneNumberFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userPhoneKey); // Retrieve phone number
  }

  // Clear all the stored data (useful for logout)
  static Future<bool> clearUserData() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.clear();
  }
}
