import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIdKey = "USERKEY";
  static String userNameKey = "USERNAMEKEY";        // Display Name
  static String userEmailKey = "USEREMAILKEY";
  static String userImageKey = "USERIMAGEKEY";
  static String userUsernameKey = "USERUSERNAMEKEY"; // Custom username

  // 🔧 Add this missing method
  Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Save methods
  Future<bool> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, userId);
  }

  Future<bool> saveUserDisplayName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, name);
  }

  Future<bool> saveUserEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, email);
  }

  Future<bool> saveUserImage(String imageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userImageKey, imageUrl);
  }

  Future<bool> saveUserUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userUsernameKey, username);
  }

  // Get methods
  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String?> getUserDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getUserImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userImageKey);
  }

  Future<String?> getUserUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userUsernameKey);
  }

  // Clear all on logout
  Future<void> clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
