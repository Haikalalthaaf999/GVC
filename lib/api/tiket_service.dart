// lib/api/tiket_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/models/model_tiket.dart';

class TiketService {
  final String baseUrl = 'https://appbioskop.mobileprojp.com/api';
  final String endpoint = '/tickets';

  // ... (Fungsi pesanTiket, getTiketByToken, hapusTiket tidak berubah) ...
  Future<bool> pesanTiket({
    required String token,
    required int jadwalId,
    required String nama,
    required int jumlah,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'schedule_id': jadwalId,
        'quantity': jumlah,
        'nama': nama,
      }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<List<Tiket>?> getTiketByToken(String token) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      return listTiketFromJson(res.body);
    }
    return null;
  }

  Future<bool> hapusTiket(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final url = Uri.parse('$baseUrl$endpoint/$id');
    final res = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    return res.statusCode == 200;
  }

  // ===================================================================
  // PERBAIKAN UTAMA ADA DI FUNGSI INI
  // ===================================================================
  Future<bool> editTiket({
    required String token,
    required int tiketId,
    required int scheduleId, // <-- 1. TAMBAHKAN PARAMETER scheduleId
    required int jumlah,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint/$tiketId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'schedule_id': scheduleId, // <-- 2. KIRIM KEMBALI schedule_id
        'quantity': jumlah,
      }),
    );

    if (response.statusCode != 200) {
      print('Gagal mengedit tiket. Status: ${response.statusCode}');
      print('Respons Body: ${response.body}');
    }

    return response.statusCode == 200;
  }
}
