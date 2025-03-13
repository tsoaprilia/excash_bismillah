import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  // Simpan Data User ke SharedPreferences
  static Future<void> saveCurrentUser(String userId, String userName, String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('user_name', userName);
    await prefs.setString('user_email', userEmail);
  }

  // Ambil Data User dari SharedPreferences
  static Future<Map<String, String>> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'user_id': prefs.getString('user_id') ?? '',
      'user_name': prefs.getString('user_name') ?? '',
      'user_email': prefs.getString('user_email') ?? '',
    };
  }

  // Hapus Data User saat Logout
  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }
}
