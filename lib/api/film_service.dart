// lib/api/film_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vgc/models/model_film.dart';

class FilmService {
  static const String baseUrl = 'https://appbioskop.mobileprojp.com/api';

  Future<List<Datum>?> getAllFilms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('TOKEN TIDAK DITEMUKAN');
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/films'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print('Status Code getFilms: ${response.statusCode}');

    if (response.statusCode == 200) {
      return listFilmFromJson(response.body);
    } else {
      return null;
    }
  }

  // FUNGSI BARU UNTUK MENGIRIM DATA DENGAN BASE64
  Future<bool> tambahFilmDenganBase64({
    required String judul,
    required String deskripsi,
    required String genre,
    required String sutradara,
    required String penulis,
    required String imageBase64,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse('$baseUrl/films'), // Endpoint API untuk menambah film
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Penting: tipe konten adalah JSON
        'Accept': 'application/json',
      },
      // Kirim semua data dalam satu body JSON
      body: jsonEncode({
        'title': judul,
        'description': deskripsi,
        'genre': genre,
        'director': sutradara,
        'writer': penulis,
        'image_base64':
            imageBase64, // Field ini harus siap diterima oleh backend
      }),
    );

    // Debugging untuk melihat respons dari server
    print('Status Code Tambah Film (Base64): ${response.statusCode}');
    print('Body Respons: ${response.body}');

    return response.statusCode == 201 || response.statusCode == 200;
  }

  // Fungsi lama (Multipart) bisa Anda hapus atau biarkan sebagai referensi
  /*
  Future<bool> tambahFilm(
    String judul,
    String deskripsi,
    String genre,
    String sutradara,
    String penulis,
    String imagePath,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/films'));
    request.headers['Authorization'] = 'Bearer $token';
    
    request.fields['title'] = judul;
    request.fields['description'] = deskripsi;
    request.fields['genre'] = genre;
    request.fields['director'] = sutradara;
    request.fields['writer'] = penulis;     
    
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final response = await request.send();
    
    return response.statusCode == 201 || response.statusCode == 200;
  }
  */

  Future<Datum?> getFilmById(int id) async {
    // ... (fungsi ini tidak perlu diubah)
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final res = await http.get(
      Uri.parse('$baseUrl/films/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body)['data'];
      return Datum.fromJson(data);
    }
    return null;
  }
}
