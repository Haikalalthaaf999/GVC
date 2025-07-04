// lib/helper/prefrence.dart (Versi FINAL dengan Studio Jadwal Lokal & Bangku Terisi)

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Pastikan ini diimpor untuk json.encode/decode

class PreferenceHelper {
  static const _keyToken = 'token';
  static const _keyNama = 'nama';
  static const _keyEmail = 'email';
  static const _keyIsAdmin = 'isAdmin';
  static const _keyJadwalStudios =
      'jadwalStudios'; // Kunci untuk map studio jadwal
  static const _keyOccupiedSeats =
      'occupiedSeats'; // Kunci untuk map bangku yang dipesan

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

  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
  }

  static Future<void> saveIsAdmin(bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsAdmin, isAdmin);
  }

  static Future<String?> getNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNama);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<bool> getIsAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsAdmin) ?? false;
  }

  // --- FUNGSI UNTUK STUDIO JADWAL LOKAL ---
  static Future<void> saveJadwalStudioMap(Map<String, String> studioMap) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyJadwalStudios, json.encode(studioMap));
  }

  static Future<Map<String, String>> getJadwalStudioMap() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyJadwalStudios);
    if (jsonString == null) {
      return {};
    }
    return Map<String, String>.from(json.decode(jsonString));
  }

  static Future<void> addOrUpdateJadwalStudio(
    String jadwalId,
    String studioName,
  ) async {
    Map<String, String> currentMap = await getJadwalStudioMap();
    currentMap[jadwalId] = studioName;
    await saveJadwalStudioMap(currentMap);
  }

  // Tambahkan fungsi ini di dalam kelas PreferenceHelper

  static Future<String?> getStudioForJadwal(String jadwalId) async {
    final Map<String, String> studioMap = await getJadwalStudioMap();
    return studioMap[jadwalId]; // Akan mengembalikan nama studio atau null jika tidak ada
  }

  // --- FUNGSI UNTUK BANGKU TERISI LOKAL ---
  static Future<Map<String, List<String>>> getOccupiedSeatsMap() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyOccupiedSeats);
    if (jsonString == null) {
      return {};
    }
    Map<String, dynamic> decoded = json.decode(jsonString);
    return decoded.map((key, value) => MapEntry(key, List<String>.from(value)));
  }

  static Future<void> saveOccupiedSeatsMap(
    Map<String, List<String>> seatsMap,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOccupiedSeats, json.encode(seatsMap));
  }

  static Future<void> addOccupiedSeats(
    String jadwalId,
    List<String> newSeats,
  ) async {
    Map<String, List<String>> currentOccupiedSeats =
        await getOccupiedSeatsMap();
    currentOccupiedSeats.putIfAbsent(jadwalId, () => []);
    currentOccupiedSeats[jadwalId]!.addAll(newSeats);
    currentOccupiedSeats[jadwalId] = currentOccupiedSeats[jadwalId]!
        .toSet()
        .toList(); // Hapus duplikat
    await saveOccupiedSeatsMap(currentOccupiedSeats);
  }

  static Future<List<String>> getOccupiedSeatsForJadwal(String jadwalId) async {
    Map<String, List<String>> currentOccupiedSeats =
        await getOccupiedSeatsMap();
    return currentOccupiedSeats[jadwalId] ?? [];
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
