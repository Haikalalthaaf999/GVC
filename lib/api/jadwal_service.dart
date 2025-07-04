// lib/api/jadwal_service.dart (FINAL - Studio dari Lokal Storage & Handle 200/201)

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/model_jadwal.dart'; // Pastikan ini diimpor
import '../models/model_film.dart'; // Pastikan ini diimpor (meskipun tidak langsung dipakai di sini, baik untuk konsistensi)
import 'package:vgc/helper/prefrence.dart'; // Import PreferenceHelper

class JadwalService {
  final String baseUrl = 'https://appbioskop.mobileprojp.com/api';

  Future<List<JadwalDatum>> getAllJadwal() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      print('Token tidak ditemukan.');
      return [];
    }

    final url = Uri.parse('$baseUrl/schedules');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('--- DEBUG: getAllJadwal Response ---');
      print('Status Code getAllJadwal: ${response.statusCode}');
      print('Body Respons getAllJadwal: ${response.body}');
      print('------------------------------------');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<JadwalDatum> jadwalFromApi = [];

        if (jsonResponse['data'] is List) {
          jadwalFromApi = (jsonResponse['data'] as List)
              .map((json) => JadwalDatum.fromJson(json))
              .toList();
        } else {
          print(
            'Format respons getAllJadwal tidak sesuai harapan (bukan list di "data").',
          );
          return [];
        }

        // Ambil map studio dari SharedPreferences
        Map<String, String> localStudios =
            await PreferenceHelper.getJadwalStudioMap();

        // Isi properti studio di setiap JadwalDatum dari data lokal
        for (var jadwal in jadwalFromApi) {
          final String jadwalIdString = jadwal.id.toString();
          if (localStudios.containsKey(jadwalIdString)) {
            jadwal.studio =
                localStudios[jadwalIdString]; // Isi studio dari lokal
          } else {
            jadwal.studio = 'N/A (Lokal)'; // Fallback jika tidak ada di lokal
          }
        }
        return jadwalFromApi; // Kembalikan daftar jadwal yang sudah diperkaya
      } else {
        print('Gagal memuat jadwal: ${response.statusCode}');
        print('Respons: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error saat mengambil semua jadwal: $e');
      return [];
    }
  }

  Future<int?> tambahJadwal({
    required int filmId,
    required String startTime,
    required String
    tempat, // Parameter ini tetap ada untuk digunakan setelah API berhasil
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      print('Token tidak ditemukan.');
      return null;
    }

    final url = Uri.parse('$baseUrl/schedules');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'film_id': filmId,
          'start_time': startTime,
          // 'studio': tempat, // DIHAPUS DARI BODY, karena API tidak menyimpannya
        }),
      );

      print('--- DEBUG: tambahJadwal Response ---');
      print('Status Code Tambah Jadwal: ${response.statusCode}');
      print('Body Respons Tambah Jadwal: ${response.body}');
      print('------------------------------------');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Menerima 200 atau 201 sebagai sukses
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final int? newJadwalId =
            jsonResponse['data']?['id']; // Ambil ID jadwal baru

        if (newJadwalId != null) {
          return newJadwalId; // Mengembalikan ID jadwal baru
        } else {
          print('Gagal mendapatkan ID jadwal dari respons API (ID null).');
          return null;
        }
      } else {
        print(
          'Gagal menambah jadwal. Status: ${response.statusCode}. Respons: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error saat menambah jadwal: $e');
      return null;
    }
  }

  Future<bool> hapusJadwal(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      print('Token tidak ditemukan saat mencoba menghapus jadwal.');
      return false;
    }

    final url = Uri.parse('$baseUrl/schedules/$id');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Status Code Hapus Jadwal: ${response.statusCode}');
      print('Body Respons Hapus Jadwal: ${response.body}');

      if (response.statusCode == 200) {
        // Hapus juga entri studio dari SharedPreferences saat jadwal dihapus
        Map<String, String> currentMap =
            await PreferenceHelper.getJadwalStudioMap();
        if (currentMap.containsKey(id.toString())) {
          currentMap.remove(id.toString());
          await PreferenceHelper.saveJadwalStudioMap(currentMap);
          print('Studio lokal untuk jadwal ID $id berhasil dihapus.');
        }
        return true;
      } else {
        print('Gagal menghapus jadwal. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error saat menghapus jadwal: $e');
      return false;
    }
  }
}
