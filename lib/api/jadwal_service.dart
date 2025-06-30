// lib/api/jadwal_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vgc/models/model_jadwal.dart';

class JadwalService {
  final String baseUrl = 'https://appbioskop.mobileprojp.com/api';

  Future<List<JadwalDatum>> getAllJadwal() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$baseUrl/schedules');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return listJadwalFromJson(response.body);
    } else {
      throw Exception('Gagal mengambil daftar jadwal.');
    }
  }

  Future<bool> tambahJadwal({
    required int filmId,
    required String startTime,
    required String tempat,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('$baseUrl/schedules');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // ===============================================================
      // PERUBAHAN TEPAT DI BARIS INI: Menyamakan key dengan model
      // ===============================================================
      body: jsonEncode({
        'film_id': filmId.toString(),
        'start_time': startTime,
        'studio': tempat, // <-- Diubah kembali menjadi 'studio'
      }),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }
}
