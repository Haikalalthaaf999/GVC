import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  static const _keyToken = 'token';
  static const _keyNama = 'nama';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> saveNama(String nama) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNama, nama);
  }

  static Future<String?> getNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNama);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
